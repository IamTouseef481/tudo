defmodule CoreWeb.Helpers.BusinessHelper do
  #   Core.BSP.Business.Sages

  @moduledoc false
  use CoreWeb, :core_helper

  alias Core.Accounts
  alias Core.PaypalPayments.SubscriptionHandler, as: Subscription
  alias Core.Schemas.Business
  alias Core.{BSP, Payments, PaypalPayments, RawBusiness, Services}
  alias CoreWeb.Helpers.EmailHelper, as: SendEmail

  #
  # Main actions
  #
  def create_business(params) do
    new()
    |> run(:is_business_exist, &is_business_exist/2, &abort/3)
    |> run(:business, &create_business/2, &abort/3)
    |> run(:update_user, &update_user/2, &abort/3)
    |> run(:business_subscription, &create_business_free_subscription/2, &abort/3)
    |> run(:local_payment, &create_local_payment/2, &abort/3)
    |> run(:branch, &make_branch_request/2, &abort/3)
    |> run(:send_in_blue_contact, &update_contact/2, &abort/3)
    |> run(:raw_bsp_claim, &check_raw_bsp_claim/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------

  defp is_business_exist(_, %{user_id: user_id, name: name}) do
    case BSP.get_business_by(%{user_id: user_id, name: name}) do
      nil -> {:ok, ["business is available"]}
      %Business{} -> {:error, ["This User have a Business with same name"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch business"], __ENV__.line)
  end

  defp create_business(_, %{rest_profile_pictures: profile_pictures} = business_params) do
    business_params = Map.merge(business_params, %{profile_pictures: profile_pictures})

    Core.BSP.create_business(business_params)
  end

  defp create_business(_, %{profile_pictures: profile_pictures} = business_params) do
    files = CoreWeb.Controllers.ImageController.upload(profile_pictures, "services")
    business_params = Map.merge(business_params, %{profile_pictures: files})

    Core.BSP.create_business(business_params)
  end

  defp create_business(_, business_params) do
    Core.BSP.create_business(business_params)
  end

  defp update_user(_, %{user_id: user_id, acl_role_id: roles} = _params) do
    case Core.Accounts.get_user!(user_id) do
      nil ->
        {:error, ["enable to fetch user"]}

      data ->
        Core.Accounts.update_user(data, %{is_bsp: true, acl_role_id: roles ++ [%{role: "bsp"}]})
    end
  end

  defp update_user(_, %{user_id: user_id} = _params) do
    case Core.Accounts.get_user!(user_id) do
      nil ->
        {:error, ["enable to fetch user"]}

      %{acl_role_id: roles} = data ->
        roles = Enum.uniq(roles ++ ["bsp"])

        Core.Accounts.update_user(data, %{
          is_bsp: true,
          acl_role_id: roles
        })
    end
  end

  defp create_business_free_subscription(
         %{business: %{id: business_id, user_id: user_id}},
         params
       ) do
    country_id =
      case params[:branch][:country_id] do
        country_id when is_nil(country_id) -> 1
        country_id -> country_id
      end

    case PaypalPayments.get_paypal_subscription_plan_by_country_and_slug("freelancer", country_id) do
      nil ->
        {:error, ["Free Plan against countryId #{country_id} is not available"]}

      %{id: plan_id} = plan ->
        #        needed to check ==> creating issue if we call exclude fun before usage
        plan =
          Subscription.update_plan_usage_information(plan, false)
          |> Subscription.exclude_plan_inactive_features()

        params =
          Map.merge(params, %{
            start_date: Date.utc_today(),
            status_id: "active",
            user_id: user_id,
            business_id: business_id,
            subscription_plan_id: plan_id,
            country_id: country_id,
            annual_price: nil,
            monthly_price: nil
          })
          |> Map.merge(plan)

        case PaypalPayments.create_paypal_subscription(params) do
          {:ok, data} ->
            {:ok, data}

          {:error, _error} ->
            {:error, ["unable to create local subscription"]}
        end
    end
  end

  defp create_local_payment(
         %{business: %{id: business_id, user_id: user_id}, business_subscription: %{id: sub_id}},
         params
       ) do
    country_id =
      case params[:branch][:country_id] do
        country_id when is_nil(country_id) -> 1
        country_id -> country_id
      end

    currency_symbol =
      case Core.Regions.get_countries(country_id) do
        %{currency_symbol: currency_symbol} -> currency_symbol
        _ -> "$"
      end

    params = %{
      user_id: user_id,
      total_transaction_amount: 0,
      paid_at: DateTime.utc_now(),
      from_bsp: true,
      payment_purpose: %{paypal_subscription_id: sub_id},
      tudo_total_amount: 0,
      business_id: business_id,
      bsp_payment_status_id: "active",
      currency_symbol: currency_symbol
    }

    case Payments.create_payment(params) do
      {:ok, data} ->
        {:ok, data}

      {:error, _error} ->
        {:error, ["unable to create local payment"]}
    end
  end

  def update_contact(%{business: %{user_id: owner_id}, branch: branch}, %{branch: branch_params}) do
    params = Map.merge(branch_params, Map.from_struct(branch))

    case Accounts.get_user!(owner_id) do
      %{email: email, profile: %{"first_name" => f_name, "last_name" => l_name}} ->
        updates_contact(Map.merge(params, %{first_name: f_name, last_name: l_name, email: email}))
        {:ok, %{}}

      nil ->
        {:error, "user doesn't exist!"}

      _ ->
        {:error, "something went wrong!"}
    end
  end

  def update_contact(_, _) do
    {:ok, ["valid!"]}
  end

  def updates_contact(
        %{
          address: address_params,
          status_id: status_id,
          services: [%{service_type_id: service_type_id, country_service_id: cs_id} | _],
          geo: geo
        } = branch_params
      ) do
    first_name =
      if Map.has_key?(branch_params, :first_name), do: branch_params.first_name, else: ""

    last_name = if Map.has_key?(branch_params, :last_name), do: branch_params.last_name, else: ""

    description =
      if Map.has_key?(branch_params, :description), do: branch_params.description, else: ""

    business_name = if Map.has_key?(branch_params, :name), do: branch_params.name, else: ""
    branch_status = if status_id == "registration_pending", do: false, else: true
    address = if Map.has_key?(branch_params, :address), do: address_params.address, else: ""
    city = if Map.has_key?(address_params, :city), do: address_params.city, else: ""
    state = if Map.has_key?(address_params, :state), do: address_params.state, else: ""
    country = if Map.has_key?(address_params, :country), do: address_params.country, else: ""
    lat_long = [geo.lat, geo.long] |> Enum.join(", ")
    email = if Map.has_key?(branch_params, :email), do: branch_params.email, else: ""

    phone =
      if Map.has_key?(branch_params, :phone),
        do: String.replace(branch_params.phone, "+", ""),
        else: ""

    social_profile =
      if Map.has_key?(branch_params, :social_profile), do: branch_params.social_profile, else: %{}

    service_name =
      case Services.get_service_by_country_service(cs_id) do
        nil -> ""
        %{name: cs_name} -> cs_name
      end

    params = %{
      email: email,
      attributes: %{
        FIRSTNAME: first_name,
        LASTNAME: last_name,
        OWNER_NAME: first_name <> " " <> last_name,
        SMS: phone,
        DOUBLE_OPT_IN: true,
        OPT_IN: true,
        BUSINESS_NAME: business_name,
        AGENT_NAME: "From TUDO Signup",
        BUSINESS_ADDRESS: Enum.join([address, city, state, country], ", "),
        LAT_LONG: lat_long,
        ALTERNATE_PHONE1: "",
        ALTERNATE_PHONE2: "",
        INDUSTRY_SECTOR_TYPE: service_type_id,
        RAW_BUSINESS_CATEGORY: service_name,
        ALTERNATE_CONTACT_PERSON: "",
        SOCIAL_FB: social_profile[:social_fb],
        SOCIAL_INSTAGRAM: social_profile[:social_instagram],
        SOCIAL_GOOGLE: social_profile[:social_google],
        SOCIAL_YELP: social_profile[:social_yelp],
        BUSINESS_PROFILE_INFO: description,
        BUSINESS_SIGNED_UP: branch_status,
        EMAIL: email
      }
    }

    indentify_url = Application.get_env(:core, :identify_host_url)

    if indentify_url == "live.tudo.app" do
      case SendEmail.update_send_in_blue_contact(params) do
        {:ok, %{"code" => _}} ->
          SendEmail.update_send_in_blue_contact(pop_in(params[:attributes][:SMS]) |> elem(1))

        response ->
          response
      end
    else
      {:ok, %{}}
    end
  end

  defp make_branch_request(
         %{
           business: %{
             id: business_id,
             settings: settings,
             name: name,
             phone: phone,
             profile_pictures: profile_pictures,
             employees_count: employees_count
           }
         },
         %{branch: branch, country_id: country_id, user_id: user_id}
       ) do
    input =
      Map.merge(branch, %{
        business_id: business_id,
        user_id: user_id,
        settings: settings,
        name: name,
        phone: phone,
        rest_profile_pictures: profile_pictures,
        employees_count: employees_count,
        is_head_office: true,
        country_id: country_id
      })

    input =
      if Map.has_key?(input, :licence_no) do
        Map.merge(input, %{business_type_id: 1, status_id: "admin_confirmation_pending"})
      else
        Map.merge(input, %{business_type_id: 2, status_id: "registration_pending"})
      end

    with {:ok, _last, all} <- CoreWeb.Helpers.BranchHelper.create_branch(input),
         %{branch: branch} <- all do
      {:ok, branch}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["enable to create branch"]}
    end
  end

  defp check_raw_bsp_claim(_, %{raw_business_id: raw_bsp_id}) when is_integer(raw_bsp_id) do
    case RawBusiness.get(raw_bsp_id) do
      nil ->
        {:error, ["Unable to find raw business"]}

      %{is_claimed: false} = bsp ->
        Core.RawBusiness.update(bsp, %{is_claimed: true, status_id: "confirmed"})

      _ ->
        {:error, ["BSP Already Claimed!"]}
    end
  end

  defp check_raw_bsp_claim(_, _), do: {:ok, ["valid!"]}
end
