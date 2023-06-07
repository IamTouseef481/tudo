defmodule CoreWeb.Helpers.UserHelper do
  @moduledoc false
  use CoreWeb, :core_helper

  alias Core.{Accounts, MetaData, Referrals, Jobs, Settings, Employees}
  alias Core.Accounts.CMRSettingsCreator
  alias Core.Schemas.{RandomTokens, User, UserInstalls}
  alias CoreWeb.Controllers.UserController
  alias CoreWeb.Helpers.{ChatGroupHelper, EmailHelper, EmployeesHelper}
  alias CoreWeb.GraphQL.Resolvers.UserResolver
  alias CoreWeb.Workers.NotificationEmailsWorker, as: Emails

  def register(params) do
    params =
      Map.merge(
        params,
        %{
          confirmation_sent_at: DateTime.utc_now(),
          acl_role_id: ["cmr"],
          purpose: "registration_activation"
        }
      )

    new()
    |> run(:email_taken, &is_email_taken/2, &abort/3)
    |> run(:user, &create_user/2, &abort/3)
    |> run(:calendar, &create_calendar/2, &abort/3)
    |> run(:install, &upsert_user_install/2, &abort/3)
    |> run(:address, &create_address/2, &abort/3)
    |> processing()
    |> run(:cmr_settings, &create_cmr_settings/2, &abort/3)
    |> run(:email_settings, &create_email_settings/2, &abort/3)
    |> run(:meta_cmr, &create_cmr_meta/2, &abort/3)
    |> run(:create_referral, &create_user_referral/2, &abort/3)
    |> run(:validate_referral, &validate_referral/2, &abort/3)
    |> run(:send_in_blue_contact, &create_contact/2, &abort/3)
    |> run(:chat_user_group, &create_chat_user_group/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  #  with minimal information
  def straight_register(params) do
    params =
      Map.merge(
        params,
        %{
          confirmation_sent_at: DateTime.utc_now(),
          acl_role_id: ["cmr"],
          purpose: "registration_activation"
        }
      )

    new()
    |> run(:email_taken, &is_email_taken/2, &abort/3)
    |> run(:user, &create_user/2, &abort/3)
    |> run(:calendar, &create_calendar/2, &abort/3)
    |> run(:install, &upsert_user_install/2, &abort/3)
    |> run(:address, &create_address/2, &abort/3)
    |> run(:send_email, &send_email/2, &abort/3)
    |> run(:cmr_settings, &create_cmr_settings/2, &abort/3)
    |> run(:email_settings, &create_email_settings/2, &abort/3)
    |> run(:meta_cmr, &create_cmr_meta/2, &abort/3)
    |> run(:create_referral, &create_user_referral/2, &abort/3)
    |> run(:validate_referral, &validate_referral/2, &abort/3)
    |> run(:send_in_blue_contact, &create_contact/2, &abort/3)
    |> run(:chat_user_group, &create_chat_user_group/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update(params) do
    new()
    |> run(:user, &update_user/2, &abort/3)
    |> run(:check_sync_google_calender_settings, &check_sync_google_calender_settings/2, &abort/3)
    |> run(:sync_google_calender, &sync_google_calender/2, &abort/3)
    |> run(:user_install, &update_user_install/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def login(params) do
    new()
    |> run(:install, &get_user_install/2, &abort/3)
    |> processing()
    |> transaction(Core.Repo, params)
  end

  #  def delete(params) do
  #    new()
  #    |> run(:user, &delete_user/2, &cancel_user_delete/4)
  #    |> transaction(Core.Repo, params)
  #  end

  def processing(sage) do
    sage
    |> run(:generate_token, &generate_token/2, &abort/3)
    |> run(:send_email, &send_email/2, &abort/3)
  end

  def invite_user(params) do
    new()
    |> run(:user_referral_code, &get_user_referral_code/2, &abort/3)
    |> run(:user_referral, &create_user_referral/2, &abort/3)
    |> run(:send_email, &email_referral_code/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def delete_cmr(user) do
    new()
    |> run(:job_status, &check_job_status/2, &abort/3)
    |> run(:delete_user, &delete_user/2, &abort/3)
    |> run(:delete_group_member, &delete_group_member/2, &abort/3)
    |> run(:logout_user_from_all_devices, &logout_user_from_all_devices/2, &abort/3)
    |> transaction(Core.Repo, user)
  end

  def delete_bsp(user) do
    new()
    |> run(:if_business_exsist, &check_if_business_exsist/2, &abort/3)
    |> run(:delete_employee_settings, &delete_employee_settings/2, &abort/3)
    |> transaction(Core.Repo, user)
  end

  # -----------------------------------------------

  def check_job_status(_, user) do
    case Jobs.get_jobs_statuses_count_for_cmr(user.id) do
      count when count > 0 ->
        {:error,
         "Sorry, we can not delete your user profile at this time. Please 'Cancel' or 'Complete Payment' or 'Finalize' the Service Requests before deleting your TUDO user profile."}

      _ ->
        {:ok, user}
    end
  end

  defp delete_user(_, user) do
    case Accounts.update_user(user, %{
           status_id: "deleted",
           deleted_at: DateTime.utc_now(),
           email: user.email <> "_" <> user.referral_code
         }) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, "Something went wrong"}
    end
  end

  defp logout_user_from_all_devices(_, user) do
    Accounts.get_list_of_fcm_token(user.id)
    |> Enum.each(fn
      fcm_token when not is_nil(fcm_token) ->
        UserResolver.delete_user_install_through_fcm_token(user.id, fcm_token)

      fcm_token when is_nil(fcm_token) ->
        :ok
    end)

    {:ok, "User Deleted Successfully"}
  end

  defp delete_group_member(_, user) do
    group_members = apply(TudoChat.Groups, :get_group_member_by_user_id, [user.id])

    result =
      Enum.reduce_while(group_members, [], fn group_member, acc ->
        case apply(TudoChatWeb.Controllers.GroupMemberController, :deleting_group_member, [
               group_member
             ]) do
          {:ok, _member} = mem ->
            {:cont, [mem | acc]}

          {:error, _error} = err ->
            {:halt, err}
        end
      end)

    case result do
      {:error, error} -> error
      _ -> {:ok, "group member deleted"}
    end
  end

  def delete_user_settings(_, %{acl_role_id: ["cmr"], id: user_id}) do
    case Settings.get_cmr_settings_by_user_id(%{user_id: user_id}) do
      [] ->
        {:ok, "no setting available"}

      [_ | _] = settings ->
        Enum.each(settings, fn setting ->
          Settings.delete_cmr_settings(setting)
        end)

        {:ok, "CMR setting deleted"}
    end
  end

  def delete_user_settings(_, %{acl_role_id: ["cmr", "bsp"]}) do
    {:ok, "no need to delete setting for bsp"}
  end

  def check_if_business_exsist(_, user) do
    business_count = Core.BSP.get_branch_by_user_id(user.id)

    if business_count > 0 do
      {:error, "You must close your business on TUDO platform before deleting your user profile"}
    else
      with {:ok, last, _all} <- delete_cmr(user) do
        {:ok, last}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    end
  end

  def delete_employee_settings(_, user) do
    case Employees.get_employee_setting_by_user_id(user.id) do
      [] ->
        {:ok, "no employee against this user"}

      [_ | _] = employee_settings ->
        Enum.each(employee_settings, fn employee_setting ->
          Employees.delete_employee_setting(employee_setting)
        end)

        {:ok, "User Deleted Successfully"}
    end
  end

  defp get_user_referral_code(_, %{user_id: user_id}) do
    case Accounts.get_user!(user_id) do
      nil -> {:error, ["unable to get user referral code"]}
      user -> {:ok, user}
    end
  end

  defp create_user_referral(_, %{email: email, user_id: user_id}) when email !== "" do
    case Referrals.create_user_referral(%{email: email, user_from_id: user_id}) do
      {:ok, referral} -> {:ok, referral}
      {:error, %Ecto.Changeset{errors: _}} -> {:error, ["User is already Referred"]}
      {:error, error} -> {:error, error}
    end
  end

  defp create_user_referral(%{user: user}, params) do
    EmployeesHelper.create_user_referral(%{user: user}, params)
  end

  defp email_referral_code(
         %{user_referral_code: %{referral_code: code, email: sender_email, profile: profile}},
         %{email: email} = attr
       ) do
    full_name =
      case profile do
        %{"first_name" => first_name, "last_name" => last_name} -> first_name <> " " <> last_name
        %{"first_name" => first_name} -> first_name
        %{"last_name" => last_name} -> last_name
        _ -> " "
      end

    friend_name =
      case attr do
        %{friend_name: friend_name} -> friend_name
        _ -> ""
      end

    case CoreWeb.Workers.NotificationEmailsWorker.perform(
           "invite_cmr",
           %{
             "referral_code" => code,
             "email" => email,
             "sender_email" => sender_email,
             "full_name" => full_name,
             "friend_name" => friend_name
           },
           "cmr"
         ) do
      {:ok, sent} -> {:ok, sent}
      {:error, _} -> {:error, ["Unable to send User Referral"]}
    end
  end

  #
  # Is email taken
  #
  defp is_email_taken(_, %{email: email}) do
    case Accounts.get_user_by_email(String.downcase(email)) do
      nil ->
        {:ok, ["valid"]}

      %User{status_id: status_id} = user when status_id == "registration_pending" ->
        {:ok, user}

      %User{} ->
        {:error, ["Email has been already taken"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in checking if Email's taken or not."], __ENV__.line)
  end

  def create_chat_user_group(%{user: %{id: user_id}}, _params) do
    case ChatGroupHelper.create_chat_user_group(user_id) do
      {:ok, _last, %{chat_user_group: group}} -> {:ok, group}
      {:error, :chat_group_not_created} -> {:ok, user_id}
      _ -> {:ok, user_id}
    end
  end

  defp create_user(
         %{email_taken: ["valid"]},
         %{profile: %{rest_profile_image: rest_profile_image}} = user_params
       ) do
    profile = Map.merge(user_params.profile, %{profile_image: rest_profile_image})
    profile = Map.delete(profile, :rest_profile_image)
    user_params = Map.merge(user_params, %{profile: profile})
    user_params |> Accounts.create_user()
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in create user 1"], __ENV__.line)
  end

  defp create_user(
         %{email_taken: ["valid"]},
         %{profile: %{profile_image: profile_image}} = user_params
       ) do
    profile_image = CoreWeb.Controllers.ImageController.upload(profile_image, "profile_images")
    user_params = Map.merge(user_params, %{profile: %{profile_image: profile_image}})
    user_params |> Accounts.create_user()
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in create user 2"], __ENV__.line)
  end

  defp create_user(%{email_taken: ["valid"]} = _effects_so_far, user_params) do
    user_params |> Accounts.create_user()
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in create user 3"], __ENV__.line)
  end

  defp create_user(
         %{email_taken: data},
         %{profile: %{rest_profile_image: rest_profile_image}} = user_params
       ) do
    user_params = Map.merge(user_params, %{acl_role_id: ["cmr", "emp"]})
    profile = Map.merge(user_params.profile, %{profile_image: rest_profile_image})
    profile = Map.delete(profile, :rest_profile_image)
    user_params = Map.merge(user_params, %{profile: profile})
    changeset = User.changeset(%User{}, user_params)
    Accounts.update_user(data, changeset.changes)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in create user 4"], __ENV__.line)
  end

  defp create_user(
         %{email_taken: data},
         %{profile: %{profile_image: profile_image}} = user_params
       ) do
    user_params = Map.merge(user_params, %{acl_role_id: ["cmr", "emp"]})
    profile_image = CoreWeb.Controllers.ImageController.upload(profile_image, "profile_images")
    user_params = Map.merge(user_params, %{profile: %{profile_image: profile_image}})
    changeset = User.changeset(%User{}, user_params)
    Accounts.update_user(data, changeset.changes)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in create user 5"], __ENV__.line)
  end

  defp create_user(%{email_taken: data}, user_params) do
    user_params = Map.merge(user_params, %{acl_role_id: ["cmr", "emp"]})
    changeset = User.changeset(%User{}, user_params)
    Accounts.update_user(data, changeset.changes)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in create user 6"], __ENV__.line)
  end

  defp update_user(
         _,
         %{user: user, profile: %{rest_profile_image: rest_profile_image}} = user_params
       ) do
    profile = Map.merge(user_params.profile, %{profile_image: rest_profile_image})
    profile = Map.delete(profile, :rest_profile_image)
    profile = Map.merge(keys_to_atoms(user.profile), profile)
    user_params = Map.merge(user_params, %{profile: profile})
    user |> Accounts.update_user(user_params)
  end

  defp update_user(
         _,
         %{user: user, profile: %{profile_image: profile_image} = profile_params} = user_params
       ) do
    profile_image = CoreWeb.Controllers.ImageController.upload(profile_image, "profile_images")
    profile_params = Map.merge(profile_params, %{profile_image: profile_image})
    profile = Map.merge(keys_to_atoms(user.profile), profile_params)
    user_params = Map.merge(user_params, %{profile: profile})
    user |> Accounts.update_user(user_params)
  end

  defp update_user(_, %{user: user, profile: profile} = user_params) do
    profile = Map.merge(keys_to_atoms(user.profile), profile)
    user_params = Map.merge(user_params, %{profile: profile})
    user |> Accounts.update_user(user_params)
  end

  defp update_user(_, %{user: user} = user_params) do
    user |> Accounts.update_user(user_params)
  end

  def check_sync_google_calender_settings(_, %{user: %{id: user_id}}) do
    case Settings.get_cmr_settings_by_slug_and_user(%{
           user_id: user_id,
           slug: "sync_google_calender"
         }) do
      [] ->
        {:ok, false}

      data ->
        value =
          data
          |> List.first()
          |> Map.get(:fields)
          |> List.first()
          |> Map.get("sync_google_calender")

        if value == true do
          {:ok, true}
        else
          {:ok, false}
        end
    end
  end

  def sync_google_calender(%{check_sync_google_calender_settings: true}, %{
        refresh_token: refresh_token,
        user: %{id: user_id}
      }) do
    Exq.enqueue_in(
      Exq,
      "default",
      1,
      CoreWeb.Workers.GoogleCalenderWorker,
      [
        refresh_token,
        user_id
      ]
    )
  end

  def sync_google_calender(_, _), do: {:ok, "Settings OFF or Not Found"}

  defp update_user_install(_, %{user: user, install: %{device_token: dt} = install_params}) do
    case Accounts.get_user_installs_by_device_token(dt) do
      nil ->
        case Accounts.create_user_installs(Map.merge(install_params, %{user_id: user.id})) do
          {:ok, install} -> {:ok, install}
          {:error, _} -> {:error, ["error while creating user install!"]}
        end

      %{} = user_install ->
        case Accounts.update_user_installs(user_install, install_params) do
          {:ok, install} -> {:ok, install}
          {:error, _} -> {:error, ["error while updating user install!"]}
        end

      exception ->
        logger(
          __MODULE__,
          exception,
          ["Something went wrong while retrieving user install"],
          __ENV__.line
        )
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create or update user installs"], __ENV__.line)
  end

  defp update_user_install(_, %{user: _, install: _}) do
    {:error, ["Device Token is missing in install params!"]}
  end

  defp update_user_install(_, _) do
    {:ok, %{}}
  end

  #
  # Create user install
  #
  def upsert_user_install(%{user: %User{id: user_id}} = effects_so_far, %{install: install}) do
    with_user = install |> Map.merge(%{user_id: user_id})
    upsert_user_install(effects_so_far, with_user)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in upserting user install 1"], __ENV__.line)
  end

  def upsert_user_install(_effects_so_far, %{device_token: dt, user_id: user_id} = install) do
    case Accounts.get_user_installs_by_user_and_device_token(user_id, dt) do
      nil ->
        UserController.create_valid_user_install(install)

      %{} = user_install ->
        UserController.update_valid_user_install(user_install, install)

      exception ->
        logger(__MODULE__, exception, ["Multiple FCM Tokens and Users found"], __ENV__.line)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create or update user install"], __ENV__.line)
  end

  def upsert_user_install(%{is_locked: {true, _}}, _params), do: {:ok, %{}}

  def upsert_user_install(_, _), do: {:ok, %{}}

  def create_calendar(
        %{email_taken: ["valid"], user: %User{id: user_id}} = _effects_so_far,
        _params
      ) do
    calendar = %{
      schedule: %{jobs: [], tasks: [], events: []},
      user_id: user_id
    }

    Core.Calendars.create_calendar(calendar)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in creating calendar"], __ENV__.line)
  end

  def create_calendar(%{user: %User{id: _user_id}} = _effects_so_far, _params), do: {:ok, "valid"}

  def create_address(%{email_taken: ["valid"], user: %User{id: user_id}} = _effects_so_far, %{
        user_address: addresses
      }) do
    Enum.each(addresses, fn address ->
      address
      |> Map.merge(%{user_id: user_id})
      |> Accounts.create_user_address()
    end)

    {:ok, ["valid"]}
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in create address"], __ENV__.line)
  end

  def create_address(_, _), do: {:ok, ["valid"]}

  #
  # Generate Random Token
  #
  def generate_token(%{user: %User{email: email}, install: %UserInstalls{id: install_id}}, %{
        purpose: purpose
      }) do
    generate_token(%{email: email, installed_id: install_id, purpose: purpose})
  end

  def generate_token(%{install: %UserInstalls{id: id}}, params) do
    params = params |> Map.merge(%{installed_id: id})
    generate_token(params)
  end

  def generate_token(%{user: %User{email: email}}, %{purpose: purpose}) do
    generate_token(%{email: email, purpose: purpose})
  end

  def generate_token(_, params) do
    generate_token(params)
  end

  defp generate_token(%{email: email, installed_id: install_id, purpose: purpose}) do
    #    email = "hammadciit@gmail.com"
    #    purpose = "registration_activation"
    random_token = %{
      purpose: purpose,
      login: email,
      device_id: install_id
    }

    EmailHelper.set_token(random_token)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error while generating token"], __ENV__.line)
  end

  defp generate_token(%{email: email, purpose: purpose}) do
    random_token = %{purpose: purpose, login: email}
    EmailHelper.set_token(random_token)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error while generating token"], __ENV__.line)
  end

  #
  # Send email confirmation
  #
  def send_email(
        %{
          user: %User{email: email, profile: %{first_name: first_name, last_name: last_name}},
          generate_token: %RandomTokens{token: token, purpose: purpose}
        },
        _params
      ) do
    send_email(%{
      email: email,
      purpose: purpose,
      template: %{"full_name" => "#{first_name} #{last_name}", "token" => token}
    })
  end

  def send_email(
        %{generate_token: %RandomTokens{token: token, login: email, purpose: purpose}},
        %{profile: %{"first_name" => first_name, "last_name" => last_name}}
      ) do
    send_email(%{
      email: email,
      purpose: purpose,
      template: %{"full_name" => "#{first_name} #{last_name}", "token" => token}
    })
  end

  def send_email(
        %{generate_token: %RandomTokens{token: token, login: email, purpose: purpose}},
        _
      ) do
    send_email(%{
      email: email,
      purpose: purpose,
      template: %{"full_name" => "user", "token" => token}
    })
  end

  def send_email(
        %{user: %User{email: email, profile: %{first_name: first_name, last_name: last_name}}},
        %{password: password}
      ) do
    send_email(%{
      email: email,
      template: %{
        "full_name" => "#{first_name || ""} #{last_name || ""}",
        "TEMP_PASSWORD" => password
      },
      purpose: "send_temporary_password"
    })
  end

  @doc """
    send_email/1
    Send Automated Emails upon events or newly signed-up members.

    TODO - convert this utc date/datetime to local time and send this in email template
  """
  def send_email(%{email: email, template: attr, purpose: purpose}) do
    datetime =
      CoreWeb.Utils.DateTimeFunctions.convert_utc_time_to_local_time()
      |> CoreWeb.Utils.DateTimeFunctions.reformat_datetime_for_emails()

    {year, _, _} = Date.utc_today() |> Date.to_erl()
    attr = Map.merge(attr, %{"date_time" => datetime, "year" => year, "email" => email})

    case Emails.perform(purpose, attr, "cmr") do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to send Email"], __ENV__.line)
  end

  defp create_cmr_settings(%{email_taken: ["valid"], user: %{id: user_id}} = _effects_so_far, _) do
    {:ok, CMRSettingsCreator.create_cmr_settings(user_id)}
  end

  defp create_cmr_settings(_, _), do: {:ok, ["valid"]}

  defp create_email_settings(%{email_taken: ["valid"], user: %{id: user_id}} = _effects_so_far, _) do
    {:ok, CMRSettingsCreator.create_email_settings(user_id)}
    #    {:ok, Task.start(CMRSettingsCreator, :create_email_settings, user_id: user_id)}
  end

  defp create_email_settings(_, _), do: {:ok, ["valid"]}

  defp create_cmr_meta(%{email_taken: ["valid"], user: %{id: user_id}} = _effects_so_far, _) do
    meta_data = %{
      user_id: user_id,
      type: "dashboard",
      statistics: %{
        scheduled: %{
          count: 0,
          walk_in: %{scheduled: 0, waiting: 0, cancelled: 0},
          home_service: %{scheduled: 0, waiting: 0, cancelled: 0},
          on_demand: %{scheduled: 0, waiting: 0, cancelled: 0}
        },
        RSVP: %{count: 0, accept_reject: 0, bids: 0},
        bid_request: %{count: 0, request: 0, response: 0},
        payments: %{
          count: 0,
          walk_in: %{dues: 0, disputes: 0, closed: 0},
          home_service: %{dues: 0, disputes: 0, closed: 0},
          on_demand: %{dues: 0, disputes: 0, closed: 0}
        },
        my_net: %{count: 0},
        calendar: %{count: 0},
        deals: %{count: 0},
        eventer: %{count: 0},
        n_ter: %{count: 0},
        reports: %{count: 0}
      }
    }

    case MetaData.create_meta_cmr(meta_data) do
      {:ok, meta} -> {:ok, meta}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create CMR Meta"], __ENV__.line)
  end

  defp create_cmr_meta(_, _), do: {:ok, ["valid"]}

  defp validate_referral(%{user: %{email: email}}, %{friend_referral_code: referral_code})
       when referral_code !== "" do
    case Accounts.get_user_by_referral_code(referral_code) do
      nil ->
        {:error, ["invalid referral code"]}

      %{id: from_id} ->
        case Referrals.get_user_referral_by(from_id, email) do
          nil -> {:error, ["unable to find user referaal"]}
          user_referral -> Referrals.update_user_referral(user_referral, %{is_accept: true})
        end
    end
  end

  defp validate_referral(_, _), do: {:ok, ["valid"]}

  @doc """
  != Might be useful in future

  phone = String.replace(mobile, "+", "")
  """
  def create_contact(%{user: %{mobile: mobile, email: email, profile: profile}}, _) do
    params = %{
      email: email,
      attributes: %{
        FIRSTNAME: profile[:first_name],
        LASTNAME: profile[:last_name],
        SMS: mobile
      }
    }

    identify_url = Application.get_env(:core, :identify_host_url)

    if identify_url == "live.tudo.app" do
      EmailHelper.create_send_in_blue_contact(params)
      {:ok, %{}}
    else
      {:ok, %{}}
    end
  end

  # --------------- Login -----------------

  def get_user_install(_effects_so_far, %{device_token: dt, user_id: user_id} = params) do
    case Accounts.get_user_installs_by_user_and_device_token(user_id, dt) do
      nil -> UserController.create_valid_user_install(params)
      %{} = user_install -> {:ok, user_install}
      _user_installs -> {:error, ["Multiple FCM Tokens and Users found"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create or update user install!"], __ENV__.line)
  end

  def get_user_install(_, _), do: {:ok, %{}}

  #  defp check_user_status(_, %{status_id: status_id}) do
  #    case status_id do
  #      "confirmed" -> {:ok, ["confirmed"]}
  #      "admin_confirmation_pending" -> {:ok, ["admin_confirmation_pending"]}
  #      "blocked" -> {:error, ["User profile is blocked"]}
  #      "rejected" -> {:error, ["User profile is rejected"]}
  #      "confirmation_pending" -> {:error, ["Your account confirmation pending"]}
  #      _ -> nil
  #    end
  #  end
  #  defp delete_user(_, user) do
  #    case Accounts.delete_user(user) do
  #      {:ok, user} -> {:ok, user}
  #      {:error, error} -> {:error, error}
  #      _ -> {:ok, ["Something went wrong, try again!"]}
  #    end
  #  end
end
