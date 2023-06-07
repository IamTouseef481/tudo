defmodule CoreWeb.Helpers.BranchHelper do
  #   Core.BSP.Branch.Sages
  @moduledoc false

  use CoreWeb, :core_helper

  import CoreWeb.Controllers.ImageController, only: [upload: 2]
  import CoreWeb.Utils.Errors

  alias Core.{BSP, BSP.BranchSettingsCreator}
  alias Core.{Accounts, PaypalPayments, Services}
  alias Core.PaypalPayments.SubscriptionHandler, as: Common

  @fetch_branch_error ["enable to fetch branch"]
  @fetch_business_error ["enable to fetch business"]

  #
  # Main actions
  #
  def create_branch(params) do
    new()
    |> run(:is_branch_exist, &is_branch_exist/2, &abort/3)
    |> branch_process
    |> run(:get_zones, &get_zones/2, &abort/3)
    |> run(:subscription, &verify_subscription_branch_usage/2, &abort/3)
    |> run(:branch, &create_branch/2, &abort/3)
    |> run(:settings, &create_settings/2, &abort/3)
    |> run(:country_services, &get_country_services/2, &abort/3)
    |> run(:service_types, &get_service_types/2, &abort/3)
    #    |> run(:services_verification, &verify_subscription_services_usage/2, &abort/3)
    |> run(:branch_services, &make_branch_services/2, &abort/3)
    |> run(:employee, &create_employee/2, &abort/3)
    |> run(:send_in_blue_contact, &create_contact/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_branch(params) do
    new()
    |> run(:is_branch_record_exist, &is_branch_record_exist/2, &abort/3)
    |> branch_process()
    |> run(:branch, &update_branch/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def branch_process(sage) do
    sage
    |> run(:is_business_exist, &is_business_exist/2, &abort/3)
  end

  defp is_business_exist(_, %{business_id: business_id, user_id: user_id}) do
    case BSP.get_business_by_user_id_and_business_id(user_id, business_id) do
      [] -> {:error, ["this business doesn't belongs to you"]}
      [data] -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @fetch_business_error, __ENV__.line)
  end

  defp is_business_exist(%{is_branch_record_exist: %{business_id: business_id}}, %{
         user_id: user_id
       }) do
    case BSP.get_business_by_user_id_and_business_id(user_id, business_id) do
      [] -> {:error, ["This business doesn't belongs to you"]}
      [data] -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @fetch_business_error, __ENV__.line)
  end

  defp is_business_exist(_, _params) do
    {:error, ["enable to check business for this branch"]}
  end

  #
  # Handle creation of branch
  #

  defp is_branch_exist(_, %{business_id: business_id, name: name}) do
    case BSP.get_branch_by(business_id, name) do
      [] ->
        {:ok, ["valid"]}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["A Branch with the same name already exist for your Business"],
          __ENV__.line
        )
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @fetch_branch_error, __ENV__.line)
  end

  #
  # Handle creation of branch
  #
  defp is_branch_record_exist(_, %{id: id}) do
    case BSP.get_branch!(id) do
      nil -> {:error, ["branch doesn't exist"]}
      data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @fetch_branch_error, __ENV__.line)
  end

  defp get_zones(_, %{country_id: country_id}) do
    case Core.GeoZones.get_geo_zone_by_country_id(country_id) do
      #      [] -> {:error, ["no zones found for this country"]}
      data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch geo zones"], __ENV__.line)
  end

  defp verify_subscription_branch_usage(_, %{business_id: business_id, main_branch: false}) do
    case PaypalPayments.get_paypal_subscription_by_business(business_id) do
      [] ->
        {:error, ["Branch can't Created. Please Upgrade Your Plan"]}

      [%{branches: branches, annual: annual} = subscription | _] ->
        Common.updated_subscription_usage(subscription, annual, %{branches: branches})
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to update subscription usage"], __ENV__.line)
  end

  defp verify_subscription_branch_usage(_, %{business_id: business_id}) do
    case PaypalPayments.get_paypal_subscription_by_business(business_id) do
      [] -> {:error, ["Branch can't Created. Please Upgrade Your Plan"]}
      [subscription | _] -> {:ok, subscription}
    end
  end

  defp create_branch(
         %{get_zones: zones},
         %{rest_licence_photos: licence_photos, rest_profile_pictures: profile_pictures} = params
       ) do
    params
    |> put(:zone_ids, zones)
    |> put(:licence_photos, licence_photos)
    |> put(:profile_pictures, profile_pictures)
    |> BSP.create_branch()
  end

  defp create_branch(
         %{get_zones: zones},
         %{licence_photos: licence_photos, profile_pictures: profile_pictures} = params
       ) do
    licence_photos = upload(licence_photos, "services")

    profile_pictures = upload(profile_pictures, "services")

    params
    |> put(:zone_ids, zones)
    |> put(:licence_photos, licence_photos)
    |> put(:profile_pictures, profile_pictures)
    |> BSP.create_branch()
  end

  defp create_branch(
         %{get_zones: zones},
         %{
           personal_identification: %{
             rest_documents_photos: documents_photos,
             documents: documents
           },
           rest_profile_pictures: profile_pictures
         } = params
       ) do
    params =
      Map.merge(params, %{
        zone_ids: zones,
        personal_identification: %{documents_photos: documents_photos, documents: documents},
        profile_pictures: profile_pictures
      })

    BSP.create_branch(params)
  end

  defp create_branch(
         %{get_zones: zones},
         %{
           personal_identification: %{documents_photos: documents_photos, documents: documents},
           profile_pictures: profile_pictures
         } = params
       ) do
    documents_photos = upload(documents_photos, "services")

    profile_pictures = upload(profile_pictures, "services")

    params
    |> put(:zone_ids, zones)
    |> put(:personal_identification, %{documents_photos: documents_photos, documents: documents})
    |> put(:profile_pictures, profile_pictures)
    |> BSP.create_branch()
  end

  defp create_branch(%{get_zones: zones}, %{rest_profile_pictures: profile_pictures} = params) do
    params
    |> put(:zone_ids, zones)
    |> put(:profile_pictures, profile_pictures)
    |> BSP.create_branch()
  end

  defp create_branch(%{get_zones: zones}, %{profile_pictures: profile_pictures} = params) do
    profile_pictures = upload(profile_pictures, "services")

    params
    |> put(:zone_ids, zones)
    |> put(:profile_pictures, profile_pictures)
    |> BSP.create_branch()
  end

  defp create_branch(%{get_zones: zones}, params) do
    params
    |> put(:zone_ids, zones)
    |> BSP.create_branch()
  end

  defp create_branch(_, _) do
    {:ok, :not_applicable}
  end

  defp create_settings(%{branch: %{id: branch_id}}, business_params) do
    BranchSettingsCreator.create_branch_settings(branch_id, business_params)
  end

  defp update_branch(
         %{is_branch_record_exist: %{location: %{coordinates: {long, lat}}} = changeset},
         %{rest_licence_photos: licence_photos, rest_profile_pictures: profile_pics} = params
       ) do
    params
    |> put(:licence_photos, licence_photos)
    |> put(:profile_pictures, profile_pics)
    |> then(fn params -> updates_branch(lat, long, changeset, params) end)
  end

  defp update_branch(
         %{is_branch_record_exist: %{location: %{coordinates: {long, lat}}} = changeset},
         %{rest_licence_photos: licence_photos} = params
       ) do
    params
    |> put(:licence_photos, licence_photos)
    |> then(fn params -> updates_branch(lat, long, changeset, params) end)
  end

  defp update_branch(
         %{is_branch_record_exist: %{location: %{coordinates: {long, lat}}} = changeset},
         %{rest_profile_pictures: profile_pics} = params
       ) do
    params
    |> put(:profile_pictures, profile_pics)
    |> then(fn params -> updates_branch(lat, long, changeset, params) end)
  end

  defp update_branch(
         %{is_branch_record_exist: %{location: %{coordinates: {long, lat}}} = changeset},
         params
       ) do
    updates_branch(lat, long, changeset, params)
  end

  defp updates_branch(lat, long, changeset, params) do
    changeset = changeset |> put(:geo, %{lat: lat, long: long})

    params = changeset |> update_json_fields_data(params)

    case BSP.update_branch(changeset, params) do
      {:ok, branch} ->
        settings = branch.settings

        keys = Map.keys(settings)

        if is_binary(hd(keys)) do
          settings
          |> keys_to_atoms()
          |> then(fn setting -> branch |> put(:settings, setting) end)
          |> ok()
        else
          branch |> ok()
        end

      {:error, changeset} ->
        changeset |> error()
    end
  end

  def update_json_fields_data(changeset, input) do
    settings = if is_nil(changeset.settings), do: %{}, else: keys_to_atoms(changeset.settings)

    identification =
      if is_nil(changeset.personal_identification) do
        %{}
      else
        keys_to_atoms(changeset.personal_identification)
      end

    input =
      case input do
        %{settings: input_settings} -> %{input | settings: Map.merge(settings, input_settings)}
        _ -> input
      end

    case input do
      %{personal_identification: input_identification} ->
        %{input | personal_identification: Map.merge(identification, input_identification)}

      _ ->
        input
    end
  end

  defp create_employee(
         %{
           is_business_exist: %{user_id: user_id},
           branch: %{id: branch_id, location: location},
           country_services: _country_services,
           branch_services: branch_services
         },
         _params
       ) do
    %{
      employee_role_id: "owner",
      employee_role_in_org: "owner",
      employee_status_id: "active",
      employee_type_id: "full_time",
      shift_schedule_id: "A",
      pay_rate_id: "monthly",
      branch_services: branch_services,
      current_location: location,
      #      manager_id: user_id,
      user_id: user_id,
      branch_id: branch_id,
      contract_begin_date: ~U[2019-01-01 04:11:08.589187Z],
      contract_end_date: ~U[2120-12-31 23:59:59Z]
    }
    |> CoreWeb.Controllers.EmployeeController.create_employee()
  end

  def create_contact(%{branch: %{status_id: _}}, %{main_branch: false, user_id: owner_id}) do
    case Accounts.get_user!(owner_id) do
      %{profile: %{"first_name" => _, "last_name" => _}} ->
        #        Business.creates_contact(Map.merge(params, %{owner_name: Enum.join([f_name, l_name, " "]), status_id: status_id}))
        {:ok, ["valid!"]}

      nil ->
        {:error, "user doesn't exist!"}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
    end

    {:ok, ["valid!"]}
  end

  def create_contact(_, _), do: {:ok, ["valid!"]}

  defp get_country_services(_, %{services: services}) do
    country_services =
      Enum.reduce_while(services, [], fn service, acc ->
        case Services.get_country_service(service.country_service_id) do
          nil ->
            {:halt,
             {:error, ["error in fetching country service: #{service.country_service_id}"]}}

          %{} = cs ->
            {:cont, [cs | acc]}
        end
      end)

    case country_services do
      {:error, error} -> {:error, error}
      country_services -> {:ok, country_services}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch country services"], __ENV__.line)
  end

  defp get_country_services(_, _), do: {:ok, :not_applicable}

  defp get_service_types(_, %{services: services}) do
    service_types =
      Enum.reduce_while(services, [], fn
        %{service_type_id: type_id}, acc ->
          case Services.get_service_type(type_id) do
            nil ->
              ["invalid service type: #{type_id}"]
              |> error()
              |> halt()

            %{} = st ->
              {:cont, [st | acc]}
          end
      end)

    case service_types do
      {:error, error} -> {:error, error}
      service_types -> {:ok, service_types}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch service type"], __ENV__.line)
  end

  defp get_service_types(_, _), do: {:ok, :not_applicable}

  defp make_branch_services(%{branch: %{id: branch_id}}, %{services: services}) do
    services
    |> Enum.map(
      &%{
        is_active: true,
        country_service_id: &1.country_service_id,
        service_type_id: &1.service_type_id,
        branch_id: branch_id
      }
    )
    |> Enum.map(&upsert_branch_services/1)
    |> Enum.map(fn {:ok, data} -> data end)
    |> ok()
  end

  defp make_branch_services(_, _params) do
    {:ok, :not_applicable}
  end

  defp upsert_branch_services(
         %{branch_id: branch_id, country_service_id: id, service_type_id: service_type_id} =
           params
       ) do
    case Services.get_branch_services_by(%{
           branch_id: branch_id,
           country_service_id: id,
           service_type_id: service_type_id
         }) do
      [] -> Services.create_branch_service(params)
      [data] -> Services.update_branch_service(data, params)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to upsert branch services"], __ENV__.line)
  end
end
