defmodule CoreWeb.Helpers.EmployeesHelper do
  #   Core.Employees.Employee.Sages
  @moduledoc false

  use CoreWeb, :core_helper

  import CoreWeb.Utils.Errors

  alias Core.{
    Accounts,
    BSP,
    Dynamics,
    Employees,
    Legals,
    MetaData,
    PaypalPayments,
    Regions,
    Services
  }

  alias Core.Jobs.JobNotificationHandler
  alias Core.PaypalPayments.SubscriptionHandler, as: Common
  alias CoreWeb.GraphQL.Resolvers.{BusinessResolver, EmployeeResolver}
  alias CoreWeb.Helpers.{UserHelper, ValidateEmployeeParamsHelper}
  alias CoreWeb.Utils.String, as: ST

  #
  # Main actions
  #
  def invite_employee(params) do
    case BSP.get_branch!(params[:branch_id]) do
      nil ->
        {:error, ["branch doesn't exist"]}

      %{location: location} ->
        Map.merge(params, %{
          employee_status_id: "pending_enrollment",
          business_owner_employee: false,
          current_location: location
        })
        |> create_employee
        |> create_employee_socket
    end
  end

  def create_employee(params) do
    new()
    |> run(:verify_self_invite, &verify_self_invite/2, &abort/3)
    |> run(:is_employee_exist, &is_employee_exist/2, &abort/3)
    |> employee_process
    |> run(:is_manager_exit, &is_manager_exit/2, &abort/3)
    |> run(:subscription, &verify_subscription_usage/2, &abort/3)
    |> run(:user, &create_user/2, &abort/3)
    #    |> run(:address, &Sages.create_address/2, &abort/3)
    |> run(:employee, &create_employee/2, &abort/3)
    #    |> run(:employee_socket, &create_employee_socket/2, &abort/3)
    |> run(:employee_setting, &create_employee_setting/2, &abort/3)
    |> run(:manage_employee, &create_manage_employee/2, &abort/3)
    |> run(:employee_service, &create_employee_service/2, &abort/3)
    |> run(:meta_bsp, &create_bsp_meta/2, &abort/3)
    #    |> run(:branch_services, &get_branch_services/2, &abort/3)
    #    |> run(:employee_services, &make_employee_services/2, &abort/3)
    |> run(:create_referral, &create_user_referral/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_employee(params) do
    new()
    |> run(:is_employee_record_exist, &is_employee_record_exist/2, &abort/3)
    |> employee_process
    |> run(:validate_employee_params, &validate_employee_params/2, &abort/3)
    |> run(:employee, &update_employee/2, &abort/3)
    |> run(:employee_socket, &update_employee_socket/2, &abort/3)
    |> run(:update_user_role, &update_user_role_as_emp/2, &abort/3)
    |> run(:update_meta_bsp, &update_meta_bsp/2, &abort/3)
    |> run(:invitation_accept_notification, &send_notification_for_accept_employment/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def employee_process(sage) do
    sage |> run(:is_branch_exit, &is_branch_exit/2, &abort/3)
  end

  # -----------------------------------------------

  #
  # Handle update subscription_usage
  #

  defp verify_subscription_usage(_, %{branch_id: branch_id, business_owner_employee: false}) do
    case BSP.get_branch!(branch_id) do
      nil ->
        {:error, ["branch doesn't exist"]}

      %{business_id: business_id} ->
        case PaypalPayments.get_paypal_subscription_by_business(business_id) do
          [] ->
            {:error, ["Employees can't invited. Please Upgrade Your Plan"]}

          [%{employees: employees, annual: annual} = subscription | _] ->
            Common.updated_subscription_usage(subscription, annual, %{employees: employees})
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch business"], __ENV__.line)
  end

  defp verify_subscription_usage(_, _) do
    {:ok, ["valid"]}
  end

  # -----------------------------------------------
  #
  # Is country exist
  #
  defp is_employee_exist(_, %{user_id: _} = params) do
    case Employees.get_employees_by(params) do
      [] -> {:ok, ["valid"]}
      _ -> {:error, ["Employee record already exists!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch Employees"], __ENV__.line)
  end

  defp is_employee_exist(_, %{user_email: user_email, branch_id: branch_id}) do
    case Accounts.get_public_user_by_email(user_email) do
      %{id: user_id} ->
        case Employees.get_employee_by_branch_id(user_id, branch_id) do
          [] -> {:ok, ["valid"]}
          _ -> {:error, ["Already Invited"]}
        end

      _ ->
        {:ok, ["valid"]}
    end
  end

  defp is_employee_exist(_, _) do
    {:ok, ["valid"]}
  end

  defp verify_self_invite(_, %{
         user_email: user_email,
         branch_id: _branch_id,
         token_user: %{email: token_user_email}
       }) do
    if user_email == token_user_email do
      {:error, ["Self Invite not Allowed"]}
    else
      {:ok, ["valid"]}
    end
  end

  defp verify_self_invite(_, %{user_id: user_id, token_user: %{id: token_user_id}}) do
    if user_id == token_user_id do
      {:error, ["Self Invite not Allowed"]}
    else
      {:ok, ["valid"]}
    end
  end

  defp verify_self_invite(_, _) do
    {:ok, ["valid"]}
  end

  #
  # Is service exist
  #
  defp is_branch_exit(_, %{branch_id: id}) do
    case Core.BSP.get_branch!(id) do
      nil -> {:error, ["branch doesn't exist"]}
      data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch Branch"], __ENV__.line)
  end

  defp is_branch_exit(_, _) do
    {:ok, ["valid"]}
  end

  defp is_manager_exit(_, %{manager_id: _manager_id, branch_id: _employee_branch_id} = params) do
    ValidateEmployeeParamsHelper.is_manager_exist(params)
  end

  defp is_manager_exit(_, _params) do
    {:ok, ["valid"]}
  end

  #  defp is_employee_record_exist(_, %{id: employee_id, user_id: user_id}) do
  #    case Employees.get_employee_by_user(%{employee_id: employee_id, user_id: user_id}) do
  #      nil -> {:error, ["employee doesn't exist"]}
  #      data -> {:ok, data}
  #    end
  #  rescue
  #    _ -> {:error, ["enable to fetch employee"]}
  #  end

  defp is_employee_record_exist(_, %{id: employee_id}) do
    case Employees.get_employee(employee_id) do
      nil -> {:error, ["employee doesn't exist"]}
      data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch Employee"], __ENV__.line)
  end

  defp validate_employee_params(_, params) do
    case ValidateEmployeeParamsHelper.validate(params) do
      {:ok, last, _all} ->
        {:ok, last}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["Something went wrong in validating employee params"],
          __ENV__.line
        )
    end
  end

  defp update_employee(%{is_employee_record_exist: changeset}, params) do
    params = Map.delete(params, :user_id)

    case ValidateEmployeeParamsHelper.update_employee(
           %{is_employee_record_exist: changeset},
           params
         ) do
      {:ok, data} ->
        {:ok, data}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  #  def set_branch_services(params) do
  #    new()
  #    |> run(:branch_services, &set_branch_services/2, &abort/3)
  #    |> transaction(Core.Repo, params)
  #  end
  #
  #  def set_branch_services(_, params) do
  #    result = params |> Enum.map(&upsert_branch_services/1)
  #    {:ok, %{branch_services: result}}
  #  end
  #
  #  defp upsert_branch_services(%{branch_id: branch_id, country_service_id: id}=params) do
  #    case Services.get_branch_services_by_branch_id(branch_id, id) do
  #      [] -> Services.create_branch_service(params)
  #      data -> Services.update_branch_service(data, params)
  #    end
  #  rescue
  #    _-> {:error, ["enable to upsert branch services"]}
  #  end

  #  defp upsert_branch_services(_, _) do
  #    {:ok, :not_applicable}
  #  end

  defp create_user(_, %{user: _user} = params) do
    with {:ok, _last, all} <- UserHelper.register(params),
         %{user: user} <- all do
      {:ok, user}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Unable to create user"], __ENV__.line)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Cannot create user 1"], __ENV__.line)
  end

  defp create_user(_, %{user_email: user_email}) do
    case Accounts.get_user_by_email(user_email) do
      nil ->
        param = %{
          email: user_email,
          confirmation_sent_at: DateTime.utc_now(),
          acl_role_id: ["cmr", "emp"],
          status_id: "registration_pending"
        }

        case Accounts.create_user_for_invite(param) do
          {:ok, user} ->
            UserHelper.send_email(%{
              email: user_email,
              purpose: "invite_cmr",
              template: %{message: "Please register yourself on TUDO using email: #{user_email}"}
            })

            {:ok, user}

          _ ->
            {:error, ["enable to create user"]}
        end

      data ->
        UserHelper.send_email(%{
          email: user_email,
          purpose: "invite_cmr",
          template: %{
            message:
              "We noticed you already an account on TUDO app. just login using email: #{user_email}"
          }
        })

        {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Cannot create user 2"], __ENV__.line)
  end

  defp create_user(_, %{user_id: user_id}) do
    {:ok, %{id: user_id}}
  end

  defp create_employee(%{user: %{id: user_id}} = _effects_so_far, params) do
    param = Map.merge(params, %{user_id: user_id})

    case Employees.get_employees_by(param) do
      [] -> Employees.create_employee(param)
      [data] -> Employees.update_employee(data, params)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Cannot create employee 1"], __ENV__.line)
  end

  defp create_employee(_, params) do
    params |> Employees.create_employee()
  end

  defp create_employee_socket({:ok, last, %{employee: %{user_id: user_id} = employee} = all}) do
    employee = reformat_employee_data_for_socket(employee)
    CoreWeb.Endpoint.broadcast("employee:cmr_id:#{user_id}", "employee", employee)
    {:ok, last, all}
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to perform employee socket"], __ENV__.line)
  end

  defp create_employee_socket({:error, error}) do
    {:error, error}
  end

  defp update_employee_socket(%{employee: %{id: employee_id} = employee}, _params) do
    employee = reformat_employee_data_for_socket(employee)
    {:ok, CoreWeb.Endpoint.broadcast("employee:employee_id:#{employee_id}", "employee", employee)}
  end

  defp update_user_role_as_emp(
         %{employee: %{user_id: emp_user_id, employee_role_id: employee_role_id}},
         %{employee_status_id: "active"} = params
       ) do
    current_role =
      case params do
        %{employee_role_id: employee_role_id}
        when employee_role_id in ["bsp", "bsp_admin", "owner"] ->
          "bsp"

        %{employee_role_id: _} ->
          "emp"

        _ ->
          if employee_role_id in ["bsp", "bsp_admin", "owner"], do: "bsp", else: "emp"
      end

    case Core.Accounts.get_user!(emp_user_id) do
      nil ->
        {:error, ["enable to fetch user"]}

      %{acl_role_id: roles} = data ->
        Core.Accounts.update_user(data, %{acl_role_id: Enum.uniq(roles ++ [current_role])})
    end
  end

  defp update_user_role_as_emp(%{employee: %{user_id: emp_user_id}}, _params) do
    case Core.Accounts.get_user!(emp_user_id) do
      nil -> {:error, ["enable to fetch user"]}
      data -> {:ok, data}
    end
  end

  def update_meta_bsp(%{employee: %{branch_id: branch_id}}, _) do
    with branch <- BSP.get_branch!(branch_id),
         :ok <-
           Core.Jobs.DashboardMetaHandler.update_meta_for_employee(branch, [
             "owner",
             "branch_manager",
             "bsp_admin"
           ]) do
      {:ok, ["Meta updated for employee"]}
    else
      _ -> {:error, ["unable to update employee meta"]}
    end
  end

  defp send_notification_for_accept_employment(
         %{employee: %{branch_id: branch_id, user_id: cmr_id}},
         %{employee_status_id: "pending_approval"}
       ) do
    %{name: name} = JobNotificationHandler.make_notification_data(cmr_id)
    params = %{cmr_profile_name: name, branch_id: branch_id}

    {:ok,
     JobNotificationHandler.send_notification_for_bsp(
       params,
       "cmr_accepts_employment_invitation_to_bsp"
     )}
  end

  defp send_notification_for_accept_employment(_, _) do
    {:ok, ["no need to send notification fr accept employment invitation"]}
  end

  def reformat_employee_data_for_socket(employee) do
    employee_setting =
      case Employees.get_employee_setting_by(employee.id) do
        [%{} = employee_setting] -> employee_setting
        _ -> nil
      end
      |> remove_structs_from_data

    employee =
      preload_all_structs_from_data_for_socket(employee)
      |> EmployeeResolver.adding_acl_parent_role_id_in_employee()
      |> Map.merge(%{employee_setting: employee_setting})
      |> snake_keys_to_camel()
      # to make keys just like GQL fields
      |> reformat_camel_keys_to_snake()

    # deleting branch location because coordinates tuple create Jason encoder issue while converting keys to camel case
    branch = add_geo(employee["branch"]) |> Map.delete("location")
    {_, employee} = get_and_update_in(employee["branch"], &{&1, branch})
    snake_user_profile = camel_keys_to_snake(employee["user"]["profile"])
    {_, employee} = get_and_update_in(employee["user"]["profile"], &{&1, snake_user_profile})

    employees =
      Enum.map(employee["branch"]["employees"], fn employee ->
        snake_user_profile = camel_keys_to_snake(employee["user"]["profile"])
        {_, employee} = get_and_update_in(employee["user"]["profile"], &{&1, snake_user_profile})
        employee
      end)

    {_, employee} = get_and_update_in(employee["branch"]["employees"], &{&1, employees})
    employee
  end

  defp reformat_camel_keys_to_snake(employee) do
    {_, _employee} =
      get_and_update_in(
        employee["branch"]["formattedBranchServices"],
        &{&1, camel_keys_to_snake(&1)}
      )

    if false == is_nil(employee["manager"]["branch"]["formattedBranchServices"]) do
      {_, _employee} =
        get_and_update_in(
          employee["manager"]["branch"]["formattedBranchServices"],
          &{&1, camel_keys_to_snake(&1)}
        )
    else
      employee
    end
  end

  def remove_structs_from_data(data) when is_nil(data), do: nil

  def remove_structs_from_data(data) do
    Enum.reduce(Map.keys(data), data, fn key, acc ->
      val = Map.get(data, key)

      if is_struct(val) and val.__struct__ not in [NaiveDateTime, DateTime, Date, Time, Geo.Point] do
        Map.delete(acc, key)
      else
        add_location(acc, key, val)
      end
    end)
    |> Map.delete(:__struct__)
  end

  defp add_location(acc, key, val) do
    if is_struct(val) and val.__struct__ == Geo.Point do
      {long, lat} = val.coordinates

      Map.put(acc, key, %{lat: lat, long: long})
      |> Map.put(:geo, %{lat: lat, long: long})
    else
      acc
    end
  end

  def preload_all_structs_from_data_for_socket(data) when is_list(data) do
    Enum.map(data, &preload_all_structs_from_data_for_socket(&1))
  end

  def preload_all_structs_from_data_for_socket(data) do
    Enum.reduce(Map.keys(data), data, fn key, acc ->
      val = Map.get(data, key)

      if is_struct(val) and val.__struct__ not in [NaiveDateTime, DateTime, Date, Time, Geo.Point] do
        fkey = String.to_atom(to_string(key) <> "_id")
        fkey_value = Map.get(data, fkey)

        if is_nil(fkey_value) and Map.has_key?(data, fkey) do
          Map.delete(acc, key)
        else
          case key do
            :manager ->
              manager =
                Employees.get_employee(fkey_value)
                |> Map.drop([:manager, :branch, :approved_by])
                |> preload_all_structs_from_data_for_socket()

              Map.merge(acc, %{manager: manager})

            :user ->
              user =
                Accounts.get_user!(fkey_value)
                |> preload_all_structs_from_data_for_socket()

              Map.merge(acc, %{user: user})

            :approved_by ->
              approved_by =
                Employees.get_employee(fkey_value)
                |> preload_all_structs_from_data_for_socket()

              Map.merge(acc, %{approved_by: approved_by})

            :business ->
              business =
                BSP.get_business_with_branches(fkey_value)
                |> format_branches()
                |> preload_all_structs_from_data_for_socket()

              Map.merge(acc, %{business: business})

            #            :business ->
            #              business = BSP.get_business(fkey_value)
            #                         |> remove_structs_from_data()
            #              Map.merge(acc, %{business: business})
            :employee_role ->
              employee_role =
                Employees.get_employee_role(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{employee_role: employee_role})

            :employee_status ->
              employee_status =
                Employees.get_employee_status(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{employee_status: employee_status})

            :employee_type ->
              employee_type =
                Employees.get_employee_type(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{employee_type: employee_type})

            :pay_rate ->
              pay_rate =
                Employees.get_pay_rate(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{pay_rate: pay_rate})

            :shift_schedule ->
              shift_schedule =
                Employees.get_shift_schedule(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{shift_schedule: shift_schedule})

            :branch ->
              branch =
                BSP.get_branch!(fkey_value)
                |> preload_all_structs_from_data_for_socket()

              Map.merge(acc, %{branch: branch})

            :licence_issuing_authority ->
              licence_issuing_authority =
                Legals.get_licence_issuing_authorities(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{licence_issuing_authority: licence_issuing_authority})

            :status ->
              status =
                Accounts.get_user_status(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{status: status})

            :city ->
              city =
                Regions.get_cities(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{city: city})

            :business_type ->
              business_type =
                BSP.get_business_type(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{business_type: business_type})

            :country ->
              country =
                Regions.get_countries(fkey_value)
                |> preload_all_structs_from_data_for_socket()

              Map.merge(acc, %{country: country})

            :language ->
              language =
                Regions.get_languages(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{language: language})

            :continent ->
              continent =
                Regions.get_continents(fkey_value)
                |> remove_structs_from_data()

              Map.merge(acc, %{continent: continent})

            :employees ->
              #  data.id is branch_id
              if is_nil(data.id) do
                Map.delete(acc, :employees)
              else
                employees =
                  Employees.get_employees_by_branch_id(data.id)
                  |> Enum.map(&Map.drop(&1, [:branch]))
                  |> preload_all_structs_from_data_for_socket()

                Map.merge(acc, %{employees: employees})
              end

            :country_service ->
              country_service =
                Services.get_country_service(fkey_value)
                |> preload_all_structs_from_data_for_socket()

              Map.merge(acc, %{country_service: country_service})

            :service ->
              service =
                Services.get_service(fkey_value)
                |> preload_all_structs_from_data_for_socket()

              Map.merge(acc, %{service: service})

            :service_group ->
              Map.merge(acc, %{service_group: Services.getting_service_group(fkey_value)})

            :service_type ->
              Map.merge(acc, %{service_type: Services.get_service_type(fkey_value)})

            :service_status ->
              Map.merge(acc, %{service_status: Services.get_service_status(fkey_value)})

            :dynamic_field ->
              if is_nil(fkey_value) do
                Map.delete(acc, key)
              else
                dynamic_field =
                  Dynamics.get_dynamic_field(fkey_value)
                  |> preload_all_structs_from_data_for_socket()

                Map.merge(acc, %{dynamic_field: dynamic_field})
              end

            :dynamic_field_tag ->
              Map.merge(acc, %{dynamic_field_tag: Dynamics.get_dynamic_field_tag(fkey_value)})

            :dynamic_field_type ->
              Map.merge(acc, %{dynamic_field_type: Dynamics.get_dynamic_field_type(fkey_value)})

            :dynamic_group ->
              dynamic_group =
                Dynamics.get_dynamic_group(fkey_value)
                |> preload_all_structs_from_data_for_socket()

              Map.merge(acc, %{dynamic_group: dynamic_group})

            :branch_services ->
              if !Map.has_key?(data, :id) or is_nil(Map.get(data, :id)) do
                Map.delete(acc, :branch_services)
              else
                branch_services =
                  Services.get_active_services_by_branch_for_invite_employee_socket(data.id)

                preloaded_branch_services_data =
                  preload_all_structs_from_data_for_socket(branch_services)

                Map.merge(acc, %{
                  branch_services: preloaded_branch_services_data,
                  formatted_branch_services:
                    BusinessResolver.make_services_grouped(branch_services)
                })

                #                branch_services = Enum.map(queried_branch_services, fn bs ->
                #                  Map.merge(bs, country_service: Services.get_country_service(bs.country_service_id))
                #                end)
                #                branch_services = Enum.map(branch_services, fn %{country_service: cs} = branch_service ->
                #                  country_service = Map.merge(cs, %{service: Services.get_service(cs.service_id)})
                #                  Map.merge(branch_service, %{country_service: country_service})
                #                end)
                #                branch_services = Enum.map(branch_services, fn %{country_service: cs} = branch_service ->
                #                  service = Map.merge(cs.service, %{service_group: Services.get_service_group(cs.service.service_group_id)})
                #                  country_service = Map.merge(cs, %{service: service})
                #                  Map.merge(branch_service, %{country_service: country_service})
                #                end)
                #                branch_services = Enum.map(branch_services, fn %{country_service: cs} = branch_service ->
                #                  service = Map.merge(cs.service, %{service_type: Services.get_service_type(cs.service.service_type_id)})
                #                  country_service = Map.merge(cs, %{service: service})
                #                  Map.merge(branch_service, %{country_service: country_service})
                #                end)
              end

            key ->
              Map.delete(acc, key)
          end
        end
      else
        add_location(acc, key, val)
      end
    end)
    |> Map.delete(:__struct__)
  end

  def format_branches(business) do
    branches =
      Enum.map(business.branches, fn branch ->
        Map.drop(branch, [
          :business,
          :__struct__,
          :status,
          :licence_issuing_authority,
          :city,
          :employees,
          :__meta__,
          :business_type,
          :branch_services,
          :country
        ])
        |> add_geo()
        |> Map.delete(:location)
      end)

    Map.merge(business, %{branches: branches})
  end

  defp create_employee_setting(%{employee: %{id: id}}, params) do
    params = Map.merge(params, %{employee_id: id})

    case Employees.get_employee_setting_by(id) do
      [] -> Employees.create_employee_setting(params)
      [employee_setting] -> Employees.update_employee_setting(employee_setting, params)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create employee setting"], __ENV__.line)
  end

  defp create_manage_employee(%{employee: %{id: employee_id}}, %{manager_id: _} = params) do
    params = Map.merge(params, %{employee_id: employee_id})

    case Employees.get_manage_employee_by(params) do
      [] -> Employees.create_manage_employee(params)
      manage_employee -> {:ok, manage_employee}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to manage employee"], __ENV__.line)
  end

  defp create_manage_employee(%{employee: %{id: _employee_id}}, _) do
    {:ok, ["valid"]}
  end

  defp create_employee_service(
         %{employee: %{id: employee_id}},
         %{branch_service_ids: branch_service_ids} = params
       ) do
    #    branch_service_ids = Services.get_branch_services_by_branch_id(params)

    params =
      Map.merge(params, %{
        employee_id: employee_id,
        start_date: params.contract_begin_date,
        end_date: params.contract_end_date
      })

    employee_services =
      Enum.map(branch_service_ids, fn branch_service_id ->
        params = Map.merge(params, %{branch_service_id: branch_service_id})

        case Services.create_employee_service(params) do
          {:ok, employee_service} ->
            {:ok, employee_service}

          {:error, error} ->
            {:error, error}

          exception ->
            logger(__MODULE__, exception, :info, __ENV__.line)
            {:ok, ["valid"]}
        end
      end)

    {:ok, employee_services}
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create employee services"], __ENV__.line)
  end

  defp create_employee_service(
         %{employee: %{id: employee_id}},
         %{
           branch_id: _branch_id,
           branch_services: branch_services,
           contract_begin_date: contract_begin_date,
           contract_end_date: contract_end_date
         }
       ) do
    params = %{
      employee_id: employee_id,
      start_date: contract_begin_date,
      end_date: contract_end_date
    }

    employee_services =
      Enum.map(branch_services, fn %{id: id} ->
        params = Map.merge(params, %{branch_service_id: id})

        case Services.create_employee_service(params) do
          {:ok, employee_service} ->
            {:ok, employee_service}

          {:error, error} ->
            {:error, error}

          exception ->
            logger(__MODULE__, exception, :info, __ENV__.line)
            {:ok, ["valid"]}
        end
      end)

    {:ok, employee_services}
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create employee services"], __ENV__.line)
  end

  defp create_employee_service(_, params) do
    {:error, ["can not create employee services, params are not correct", params]}
  end

  defp create_bsp_meta(
         %{employee: %{id: employee_id, branch_id: branch_id} = employee},
         _params
       ) do
    case MetaData.get_dashboard_meta_by_employee_id(employee_id, branch_id, "dashboard") do
      [] ->
        make_meta_data(employee)
        |> create_meta_bsp()

      [meta] ->
        {:ok, meta}

      [meta | _] ->
        {:ok, meta}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create employee meta"], __ENV__.line)
  end

  def create_meta_bsp(meta_data) do
    case MetaData.create_meta_bsp(meta_data) do
      {:ok, meta} -> {:ok, meta}
      {:error, error} -> {:error, error}
    end
  end

  def make_meta_data(%{id: employee_id, user_id: user_id, branch_id: branch_id}) do
    %{
      employee_id: employee_id,
      user_id: user_id,
      branch_id: branch_id,
      type: "dashboard",
      statistics: %{
        leads: %{count: 0},
        prospects: %{count: 0},
        proposals: %{count: 0, requests: 0, proposals: 0},
        scheduled: %{
          count: 0,
          walk_in: %{scheduled: 0, waiting: 0, cancelled: 0},
          home_service: %{scheduled: 0, waiting: 0, cancelled: 0},
          on_demand: %{scheduled: 0, waiting: 0, cancelled: 0}
        },
        RSVP: %{count: 0, accept_reject: 0, bids: 0},
        accounter: %{
          count: 0,
          walk_in: %{overdues: 0, disputes: 0, closed: 0, invoiced: 0},
          home_service: %{overdues: 0, disputes: 0, closed: 0},
          on_demand: %{overdues: 0, disputes: 0, closed: 0}
        },
        bus_net: %{count: 0},
        n_ter: %{count: 0},
        calendar: %{count: 0},
        myemployees: %{count: 0},
        promos: %{count: 0},
        eventer: %{count: 0},
        reports: %{count: 0},
        business_setting: %{count: 0}
      }
    }
  end

  def create_user_referral(%{user: user}, _) do
    user =
      case user do
        user when is_struct(user) -> user
        %{id: user_id} -> Accounts.get_user!(user_id)
      end

    referral_code = ST.string_of_length()

    if false == is_nil(user) do
      case Accounts.update_user(user, %{referral_code: referral_code}) do
        {:error, _} ->
          referral_code = ST.string_of_length()
          Accounts.update_user(user, %{referral_code: referral_code})

        {:ok, user} ->
          {:ok, user}
      end
    else
      {:error, ["user does not exist"]}
    end
  end
end
