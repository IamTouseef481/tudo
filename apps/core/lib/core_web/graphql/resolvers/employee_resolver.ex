defmodule CoreWeb.GraphQL.Resolvers.EmployeeResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias Core.{Acl, Employees}
  alias CoreWeb.Controllers.EmployeeController
  alias CoreWeb.GraphQL.Resolvers.BusinessResolver

  @common_error ["error while getting parent role"]

  def employees(_, _, _) do
    {:ok, Employees.list_employees()}
  end

  def employee_pay_rates(_, _, _) do
    {:ok, Employees.list_pay_rates()}
  end

  def employee_shift_schedules(_, _, _) do
    {:ok, Employees.list_shift_schedules()}
  end

  def employee_roles(_, _, _) do
    {:ok, Employees.list_employee_roles()}
  end

  def employee_types(_, _, _) do
    {:ok, Employees.list_employee_types()}
  end

  def employee_statuses(_, _, _) do
    case Employees.list_employee_statuses() do
      [] -> {:ok, []}
      data -> {:ok, data}
    end
  end

  def employee_services(_, _, _) do
    {:ok, Core.Services.list_employee_services()}
  end

  def invite_employee(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{token_user: current_user})

    case CoreWeb.Controllers.EmployeeController.invite_employee(input) do
      {:ok, data} ->
        case add_acl_parent_role_id_in_employee(data) do
          {:error, error} -> {:error, error}
          data -> {:ok, data}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to send Employment Invitation"], __ENV__.line)
  end

  def update_employee(_, %{input: input}, %{context: %{current_user: %{id: id}}}) do
    input =
      case input do
        %{branch_id: branch_id} ->
          Map.merge(input, %{user_id: id, branch_id: branch_id})

        %{id: employee_id} ->
          case Employees.get_employee(employee_id) do
            %{branch_id: branch_id} ->
              Map.merge(input, %{user_id: id, branch_id: branch_id})

            _ ->
              Map.merge(input, %{user_id: id, branch_id: nil})
          end
      end

    case CoreWeb.Controllers.EmployeeController.update_employee(input) do
      {:ok, data} ->
        case add_acl_parent_role_id_in_employee(data) do
          {:error, error} -> {:error, error}
          data -> {:ok, data}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_location_employee(_, %{input: input}, %{context: %{current_user: %{id: id}}}) do
    case Employees.get_employee(input.id) do
      nil ->
        {:error, ["employee doesn't exist"]}

      employee ->
        if owner_or_manager_validity(%{user_id: id, branch_id: employee.branch_id}) or
             id == employee.user_id do
          updated_current_location = %Geo.Point{
            coordinates: {input.current_location.long, input.current_location.lat},
            srid: 4326
          }

          case Employees.update_employee(employee, %{current_location: updated_current_location}) do
            {:error, error} ->
              {:error, error}

            {:ok, %{current_location: %{coordinates: {long, lat}}} = employee} ->
              employee = Map.merge(employee, %{current_location: %{lat: lat, long: long}})
              {:ok, employee}
          end
        else
          {:error, ["You are not allowed to perform this action!"]}
        end
    end
  end

  def delete_employee(_, %{input: input}, %{context: %{current_user: %{id: id}}}) do
    input = Map.merge(input, %{user_id: id})

    case CoreWeb.Controllers.EmployeeController.delete_employee(input) do
      {:ok, data} ->
        case add_acl_parent_role_id_in_employee(data) do
          {:error, error} -> {:error, error}
          data -> {:ok, data}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_employees_by_branch_id(_, %{input: %{branch_id: id}}, _) do
    employees = Employees.get_employees_by_branch_id(id)

    case add_acl_parent_role_id_in_employee(employees) do
      {:error, error} -> {:error, error}
      data -> {:ok, data}
    end
  end

  def get_employees_by_branch_id(_, _, _) do
    {:ok, %{employees: []}}
  end

  def get_employees_by_user_id(_, %{input: %{user_id: id}}, _) do
    employees = Employees.get_employees_by_user_id_of_confirmed_brnach(id)

    case add_acl_parent_role_id_in_employee(employees) do
      {:error, error} -> {:error, error}
      data -> {:ok, data}
    end
  end

  def get_employees_by_user_id(_, _, _) do
    {:ok, %{employees: []}}
  end

  def create_pay_rate(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.create_pay_rate(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_pay_rate(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.get_pay_rate(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_pay_rate(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.update_pay_rate(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def delete_pay_rate(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.delete_pay_rate(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def create_employee_role(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.create_employee_role(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_employee_role(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.get_employee_role(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_employee_role(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.update_employee_role(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def delete_employee_role(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.delete_employee_role(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def create_employee_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.create_employee_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_employee_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.get_employee_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_employee_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.update_employee_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def delete_employee_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.delete_employee_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def create_employee_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.create_employee_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_employee_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.get_employee_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_employee_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.update_employee_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def delete_employee_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EmployeeController.delete_employee_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def create_employee_setting(_, %{input: %{employee_id: id} = input}, _) do
    case Employees.get_employee_setting_by(id) do
      [] -> EmployeeController.create_employee_setting(input)
      [setting] -> EmployeeController.update_employee_setting(setting, input)
      _ -> {:error, ["error while getting employee setting"]}
    end
  end

  def get_employee_setting(_, %{input: %{employee_id: id}}, _) do
    case Employees.get_employee_setting_by(id) do
      [] -> {:error, ["employee setting doesn't exist!"]}
      [employee_setting] -> {:ok, employee_setting}
      _ -> {:error, ["error while getting employee setting"]}
    end
  end

  def update_employee_setting(_, %{input: %{employee_id: id} = input}, _) do
    case Employees.get_employee_setting_by(id) do
      [] -> {:error, ["employee setting doesn't exist!"]}
      [setting] -> EmployeeController.update_employee_setting(setting, input)
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def delete_employee_setting(_, %{input: %{employee_id: id}}, _) do
    case Employees.get_employee_setting_by(id) do
      [] -> {:error, ["employee setting doesn't exist!"]}
      [setting] -> EmployeeController.delete_employee_setting(setting)
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  #  def create_manage_employee(_, %{input: input}, _) do
  #    case Employees.create_manage_employee(input) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #    end
  #  end
  #  def get_manage_employee(_, %{input: %{employee_id: id} = input}, _) do
  #    case Employees.get_manage_employee_by(id) do
  #      nil -> {:error, ["manage employee doesn't exist!"]}
  #      manage_employee -> {:ok, manage_employee}
  #      _ -> {:error, ["Unexpected error occurred, try again!"]}
  #    end
  #  end
  #  def update_manage_employee(_, %{input: %{id: id} = input}, _) do
  #    case Employees.get_manage_employee(id) do
  #      nil -> {:error, ["manage employee doesn't exist!"]}
  #      manage_employee -> Employees.update_manage_employee(manage_employee, input)
  #      _ -> {:error, ["Unexpected error occurred, try again!"]}
  #    end
  #  end
  #  def delete_manage_employee(_, %{input: %{id: id}}, _) do
  #    case Employees.get_manage_employee(id) do
  #      nil -> {:error, ["manage employee doesn't exist!"]}
  #      manage_employee -> Employees.delete_manage_employee(manage_employee)
  #      _ -> {:error, ["Unexpected error occurred, try again!"]}
  #    end
  #  end

  def create_shift_schedule(_, %{input: input}, _) do
    case Employees.create_shift_schedule(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_shift_schedule(_, %{input: %{id: id}}, _) do
    case Employees.get_shift_schedule(id) do
      nil -> {:error, ["Business Shift Schedule doesn't exist!"]}
      %{} = shift_schedule -> {:ok, shift_schedule}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def update_shift_schedule(_, %{input: %{id: id} = input}, _) do
    case Employees.get_shift_schedule(id) do
      nil -> {:error, ["Business Shift Schedule doesn't exist!"]}
      %{} = shift_schedule -> Employees.update_shift_schedule(shift_schedule, input)
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def delete_shift_schedule(_, %{input: %{id: id}}, _) do
    case Employees.get_shift_schedule(id) do
      nil -> {:error, ["Business Shift Schedule doesn't exist!"]}
      %{} = shift_schedule -> Employees.delete_shift_schedule(shift_schedule)
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def create_employee_service(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case CoreWeb.Controllers.EmployeeController.create_employee_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_employee_service(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case CoreWeb.Controllers.EmployeeController.update_employee_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_employee_service(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case CoreWeb.Controllers.EmployeeController.delete_employee_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def add_acl_parent_role_id_in_employee(employees) when is_list(employees) do
    Enum.map(employees, &add_acl_parent_role_id_in_employee(&1))
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  def add_acl_parent_role_id_in_employee(%{employee_role_id: employee_role_id} = employee) do
    employee =
      case Acl.get_acl_role(employee_role_id) do
        %{parent: parent} -> Map.merge(employee, %{acl_parent_role_id: parent})
        _ -> employee
      end

    case Core.BSP.get_branch!(employee.branch_id) do
      %{} = branch ->
        Map.merge(employee, %{
          branch: BusinessResolver.attach_grouped_branch_services_to_branch(branch)
        })

      _ ->
        employee
    end
  end

  def adding_acl_parent_role_id_in_employee(employees) when is_list(employees) do
    Enum.map(employees, &add_acl_parent_role_id_in_employee(&1))
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  def adding_acl_parent_role_id_in_employee(%{employee_role_id: employee_role_id} = employee) do
    _employee =
      case Acl.get_acl_role(employee_role_id) do
        %{parent: parent} -> Map.merge(employee, %{acl_parent_role_id: parent})
        _ -> employee
      end
  end
end
