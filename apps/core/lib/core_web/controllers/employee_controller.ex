defmodule CoreWeb.Controllers.EmployeeController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.{Employees, Services}
  alias Core.Schemas.EmployeeRole
  alias CoreWeb.Helpers.{EmployeesHelper, ServiceHelper}

  def validity_for_employee(%{user_id: user_id, branch_id: branch_id}) do
    if Employees.get_owner_or_manager_by_user_and_branch(user_id, branch_id) != nil do
      true
    else
      false
    end
  end

  def invite_employee(%{token_user: user, branch_id: branch_id} = params) do
    if validity_for_employee(%{user_id: user.id, branch_id: branch_id}) do
      with {:ok, _last, all} <- EmployeesHelper.invite_employee(params),
           %{employee: data} <- all do
        Core.Jobs.JobNotificationHandler.send_notification_for_invite_employee(all, branch_id)
        {:ok, data}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def create_employee(params) do
    with {:ok, _last, all} <- EmployeesHelper.create_employee(params),
         %{employee: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def update_employee(%{employee_status_id: "active"} = params) do
    if validity_for_employee(params) do
      with {:ok, _last, all} <- EmployeesHelper.update_employee(params),
           %{employee: data} <- all do
        {:ok, data}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def update_employee(params) do
    with {:ok, _last, all} <- EmployeesHelper.update_employee(params),
         %{employee: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def delete_employee(%{id: id, user_id: user_id}) do
    %{branch_id: branch_id} = Employees.get_employee(id)

    if validity_for_employee(%{user_id: user_id, branch_id: branch_id}) do
      case Employees.get_employee!(id) do
        nil -> {:error, ["Data doesn't exist!"]}
        data -> Employees.delete_employee(data)
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def create_employee_service(%{employee_id: employee_id, user_id: user_id} = params) do
    %{branch_id: branch_id} = Employees.get_employee(employee_id)

    if validity_for_employee(%{user_id: user_id, branch_id: branch_id}) do
      with {:ok, _last, all} <- ServiceHelper.create_employee_service(params),
           %{employee_service: employee_service} <- all do
        {:ok, employee_service}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def update_employee_service(%{employee_id: employee_id, user_id: user_id} = params) do
    %{branch_id: branch_id} = Employees.get_employee(employee_id)

    if validity_for_employee(%{user_id: user_id, branch_id: branch_id}) do
      with {:ok, _last, all} <- ServiceHelper.update_employee_service(params),
           %{employee_service: employee_service} <- all do
        {:ok, employee_service}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def delete_employee_service(%{id: id, user_id: user_id}) do
    %{branch_service_id: branch_service_id} = Services.get_employee_service(id)
    %{branch_id: branch_id} = Services.get_branch_service(branch_service_id)

    if validity_for_employee(%{user_id: user_id, branch_id: branch_id}) do
      case Services.get_employee_service_by_id(id) do
        [] -> {:error, ["Employee service doesn't exist"]}
        [data] -> Services.delete_employee_service(data)
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def create_pay_rate(input) do
    if owner_or_manager_validity(input) do
      case Employees.create_pay_rate(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def get_pay_rate(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_pay_rate(id) do
        nil -> {:error, ["Employee Pay Rate doesn't exist!"]}
        %{} = pay_rate -> {:ok, pay_rate}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't retrieve"], __ENV__.line)
  end

  def update_pay_rate(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_pay_rate(id) do
        nil -> {:error, ["Employee Pay Rate doesn't exist!"]}
        %{} = pay_rate -> Employees.update_pay_rate(pay_rate, input)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't update"], __ENV__.line)
  end

  def delete_pay_rate(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_pay_rate(id) do
        nil -> {:error, ["Employee Pay Rate doesn't exist!"]}
        %{} = pay_rate -> Employees.delete_pay_rate(pay_rate)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't delete"], __ENV__.line)
  end

  def create_employee_role(input) do
    if owner_or_manager_validity(input) do
      case Employees.create_employee_role(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't insert"], __ENV__.line)
  end

  def get_employee_role(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_employee_role(id) do
        nil -> {:error, ["employee role doesn't exist!"]}
        %{} = employee_role -> {:ok, employee_role}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't retrieve"], __ENV__.line)
  end

  def update_employee_role(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_employee_role(id) do
        nil -> {:error, ["employee role doesn't exist!"]}
        %{} = employee_role -> Employees.update_employee_role(employee_role, input)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't update"], __ENV__.line)
  end

  def delete_employee_role(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_employee_role(id) do
        nil -> {:error, ["employee role doesn't exist!"]}
        %{} = employee_role -> Employees.delete_employee_role(employee_role)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't delete"], __ENV__.line)
  end

  def create_employee_status(input) do
    if owner_or_manager_validity(input) do
      case Employees.create_employee_status(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't insert"], __ENV__.line)
  end

  def get_employee_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_employee_status(id) do
        nil -> {:error, ["employee status doesn't exist!"]}
        %{} = employee_status -> {:ok, employee_status}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't retrieve"], __ENV__.line)
  end

  def update_employee_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_employee_status(id) do
        nil -> {:error, ["employee status doesn't exist!"]}
        %{} = employee_status -> Employees.update_employee_status(employee_status, input)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't update"], __ENV__.line)
  end

  def delete_employee_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_employee_status(id) do
        nil -> {:error, ["employee status doesn't exist!"]}
        %{} = employee_status -> Employees.delete_employee_status(employee_status)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't delete"], __ENV__.line)
  end

  def create_employee_type(input) do
    if owner_or_manager_validity(input) do
      case Employees.create_employee_type(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't insert"], __ENV__.line)
  end

  def get_employee_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_employee_type(id) do
        nil -> {:error, ["employee type doesn't exist!"]}
        %{} = employee_type -> {:ok, employee_type}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't retrieve"], __ENV__.line)
  end

  def update_employee_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_employee_type(id) do
        nil -> {:error, ["employee type doesn't exist!"]}
        %{} = employee_type -> Employees.update_employee_type(employee_type, input)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't update"], __ENV__.line)
  end

  def delete_employee_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Employees.get_employee_type(id) do
        nil -> {:error, ["employee type doesn't exist!"]}
        %{} = employee_type -> Employees.delete_employee_type(employee_type)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't delete"], __ENV__.line)
  end

  def create_employee_setting(input) do
    case Employees.get_employee(input.employee_id) do
      nil ->
        {:error, ["employee doesn't exist"]}

      %{} ->
        case Employees.create_employee_setting(input) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
          _ -> {:error, ["error in creating employee setting"]}
        end
    end
  end

  def update_employee_setting(setting, input) do
    case Employees.update_employee_setting(setting, input) do
      {:ok, setting} -> {:ok, setting}
      {:error, error} -> {:error, error}
      _ -> {:error, ["error in updating employee setting"]}
    end
  end

  def delete_employee_setting(setting) do
    case Employees.delete_employee_setting(setting) do
      {:ok, setting} -> {:ok, setting}
      {:error, error} -> {:error, error}
      _ -> {:error, ["error in deleting employee setting"]}
    end
  end

  def index(conn, _params) do
    employee_roles = Employees.list_employee_roles()
    render(conn, "index.html", employee_roles: employee_roles)
  end

  def new(conn, _params) do
    changeset = Employees.change_employee_role(%EmployeeRole{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"employee_role" => employee_role_params}) do
    case Employees.create_employee_role(employee_role_params) do
      {:ok, _employee_role} ->
        conn
        |> put_flash(:info, "Employee role created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    employee_role = Employees.get_employee_role!(id)
    render(conn, "show.html", employee_role: employee_role)
  end

  def edit(conn, %{"id" => id}) do
    employee_role = Employees.get_employee_role!(id)
    changeset = Employees.change_employee_role(employee_role)
    render(conn, "edit.html", employee_role: employee_role, changeset: changeset)
  end

  def update(conn, %{"id" => id, "employee_role" => employee_role_params}) do
    employee_role = Employees.get_employee_role!(id)

    case Employees.update_employee_role(employee_role, employee_role_params) do
      {:ok, _employee_role} ->
        conn
        |> put_flash(:info, "Employee role updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", employee_role: employee_role, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    employee_role = Employees.get_employee_role!(id)
    {:ok, _employee_role} = Employees.delete_employee_role(employee_role)

    conn
    |> put_flash(:info, "Employee role deleted successfully.")
  end
end
