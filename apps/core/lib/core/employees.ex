defmodule Core.Employees do
  @moduledoc """
  The Employees context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{
    Branch,
    Business,
    Employee,
    EmployeeRole,
    EmployeeSetting,
    EmployeeStatus,
    EmployeeType,
    ManageEmployee,
    PayRate,
    ShiftSchedule,
    User,
    Job,
    BranchService
  }

  @doc """
  Returns the list of employee_roles.

  ## Examples

      iex> list_employee_roles()
      [%EmployeeRole{}, ...]

  """
  def list_employee_roles do
    Repo.all(EmployeeRole)
  end

  @doc """
  Gets a single employee_role.

  Raises `Ecto.NoResultsError` if the Employee role does not exist.

  ## Examples

      iex> get_employee_role!(123)
      %EmployeeRole{}

      iex> get_employee_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_employee_role!(id), do: Repo.get!(EmployeeRole, id)
  def get_employee_role(id), do: Repo.get(EmployeeRole, id)

  @doc """
  Creates a employee_role.

  ## Examples

      iex> create_employee_role(%{field: value})
      {:ok, %EmployeeRole{}}

      iex> create_employee_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_employee_role(attrs \\ %{}) do
    %EmployeeRole{}
    |> EmployeeRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a employee_role.

  ## Examples

      iex> update_employee_role(employee_role, %{field: new_value})
      {:ok, %EmployeeRole{}}

      iex> update_employee_role(employee_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_employee_role(%EmployeeRole{} = employee_role, attrs) do
    employee_role
    |> EmployeeRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a EmployeeRole.

  ## Examples

      iex> delete_employee_role(employee_role)
      {:ok, %EmployeeRole{}}

      iex> delete_employee_role(employee_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employee_role(%EmployeeRole{} = employee_role) do
    Repo.delete(employee_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking employee_role changes.

  ## Examples

      iex> change_employee_role(employee_role)
      %Ecto.Changeset{source: %EmployeeRole{}}

  """
  def change_employee_role(%EmployeeRole{} = employee_role) do
    EmployeeRole.changeset(employee_role, %{})
  end

  @doc """
  Returns the list of employee_statuses.

  ## Examples

      iex> list_employee_statuses()
      [%EmployeeStatus{}, ...]

  """
  def list_employee_statuses do
    Repo.all(EmployeeStatus)
  end

  @doc """
  Gets a single employee_status.

  Raises `Ecto.NoResultsError` if the Employee status does not exist.

  ## Examples

      iex> get_employee_status!(123)
      %EmployeeStatus{}

      iex> get_employee_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_employee_status!(id), do: Repo.get!(EmployeeStatus, id)
  def get_employee_status(id), do: Repo.get(EmployeeStatus, id)

  @doc """
  Creates a employee_status.

  ## Examples

      iex> create_employee_status(%{field: value})
      {:ok, %EmployeeStatus{}}

      iex> create_employee_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_employee_status(attrs \\ %{}) do
    %EmployeeStatus{}
    |> EmployeeStatus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a employee_status.

  ## Examples

      iex> update_employee_status(employee_status, %{field: new_value})
      {:ok, %EmployeeStatus{}}

      iex> update_employee_status(employee_status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_employee_status(%EmployeeStatus{} = employee_status, attrs) do
    employee_status
    |> EmployeeStatus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a EmployeeStatus.

  ## Examples

      iex> delete_employee_status(employee_status)
      {:ok, %EmployeeStatus{}}

      iex> delete_employee_status(employee_status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employee_status(%EmployeeStatus{} = employee_status) do
    Repo.delete(employee_status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking employee_status changes.

  ## Examples

      iex> change_employee_status(employee_status)
      %Ecto.Changeset{source: %EmployeeStatus{}}

  """
  def change_employee_status(%EmployeeStatus{} = employee_status) do
    EmployeeStatus.changeset(employee_status, %{})
  end

  @doc """
  Returns the list of employee_types.

  ## Examples

      iex> list_employee_types()
      [%EmployeeType{}, ...]

  """
  def list_employee_types do
    Repo.all(EmployeeType)
  end

  @doc """
  Gets a single employee_type.

  Raises `Ecto.NoResultsError` if the Employee type does not exist.

  ## Examples

      iex> get_employee_type!(123)
      %EmployeeType{}

      iex> get_employee_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_employee_type!(id), do: Repo.get!(EmployeeType, id)
  def get_employee_type(id), do: Repo.get(EmployeeType, id)

  @doc """
  Creates a employee_type.

  ## Examples

      iex> create_employee_type(%{field: value})
      {:ok, %EmployeeType{}}

      iex> create_employee_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_employee_type(attrs \\ %{}) do
    %EmployeeType{}
    |> EmployeeType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a employee_type.

  ## Examples

      iex> update_employee_type(employee_type, %{field: new_value})
      {:ok, %EmployeeType{}}

      iex> update_employee_type(employee_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_employee_type(%EmployeeType{} = employee_type, attrs) do
    employee_type
    |> EmployeeType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a EmployeeType.

  ## Examples

      iex> delete_employee_type(employee_type)
      {:ok, %EmployeeType{}}

      iex> delete_employee_type(employee_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employee_type(%EmployeeType{} = employee_type) do
    Repo.delete(employee_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking employee_type changes.

  ## Examples

      iex> change_employee_type(employee_type)
      %Ecto.Changeset{source: %EmployeeType{}}

  """
  def change_employee_type(%EmployeeType{} = employee_type) do
    EmployeeType.changeset(employee_type, %{})
  end

  @doc """
  Returns the list of shift_schedules.

  ## Examples

      iex> list_shift_schedules()
      [%ShiftSchedule{}, ...]

  """
  def list_shift_schedules do
    Repo.all(ShiftSchedule)
  end

  @doc """
  Gets a single shift_schedule.

  Raises `Ecto.NoResultsError` if the Shift schedule does not exist.

  ## Examples

      iex> get_shift_schedule!(123)
      %ShiftSchedule{}

      iex> get_shift_schedule!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shift_schedule!(id), do: Repo.get!(ShiftSchedule, id)
  def get_shift_schedule(id), do: Repo.get(ShiftSchedule, id)

  @doc """
  Creates a shift_schedule.

  ## Examples

      iex> create_shift_schedule(%{field: value})
      {:ok, %ShiftSchedule{}}

      iex> create_shift_schedule(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shift_schedule(attrs \\ %{}) do
    %ShiftSchedule{}
    |> ShiftSchedule.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shift_schedule.

  ## Examples

      iex> update_shift_schedule(shift_schedule, %{field: new_value})
      {:ok, %ShiftSchedule{}}

      iex> update_shift_schedule(shift_schedule, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shift_schedule(%ShiftSchedule{} = shift_schedule, attrs) do
    shift_schedule
    |> ShiftSchedule.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ShiftSchedule.

  ## Examples

      iex> delete_shift_schedule(shift_schedule)
      {:ok, %ShiftSchedule{}}

      iex> delete_shift_schedule(shift_schedule)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shift_schedule(%ShiftSchedule{} = shift_schedule) do
    Repo.delete(shift_schedule)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shift_schedule changes.

  ## Examples

      iex> change_shift_schedule(shift_schedule)
      %Ecto.Changeset{source: %ShiftSchedule{}}

  """
  def change_shift_schedule(%ShiftSchedule{} = shift_schedule) do
    ShiftSchedule.changeset(shift_schedule, %{})
  end

  @doc """
  Returns the list of pay_rates.

  ## Examples

      iex> list_pay_rates()
      [%PayRate{}, ...]

  """
  def list_pay_rates do
    Repo.all(PayRate)
  end

  @doc """
  Gets a single pay_rate.

  Raises `Ecto.NoResultsError` if the Pay rate does not exist.

  ## Examples

      iex> get_pay_rate!(123)
      %PayRate{}

      iex> get_pay_rate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pay_rate!(id), do: Repo.get!(PayRate, id)
  def get_pay_rate(id), do: Repo.get(PayRate, id)

  @doc """
  Creates a pay_rate.

  ## Examples

      iex> create_pay_rate(%{field: value})
      {:ok, %PayRate{}}

      iex> create_pay_rate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pay_rate(attrs \\ %{}) do
    %PayRate{}
    |> PayRate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pay_rate.

  ## Examples

      iex> update_pay_rate(pay_rate, %{field: new_value})
      {:ok, %PayRate{}}

      iex> update_pay_rate(pay_rate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pay_rate(%PayRate{} = pay_rate, attrs) do
    pay_rate
    |> PayRate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PayRate.

  ## Examples

      iex> delete_pay_rate(pay_rate)
      {:ok, %PayRate{}}

      iex> delete_pay_rate(pay_rate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pay_rate(%PayRate{} = pay_rate) do
    Repo.delete(pay_rate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pay_rate changes.

  ## Examples

      iex> change_pay_rate(pay_rate)
      %Ecto.Changeset{source: %PayRate{}}

  """
  def change_pay_rate(%PayRate{} = pay_rate) do
    PayRate.changeset(pay_rate, %{})
  end

  @doc """
  Returns the list of employees.

  ## Examples

      iex> list_employees()
      [%Employee{}, ...]

  """
  def list_employees do
    Repo.all(Employee)
  end

  @doc """
  Gets a single employee.

  Raises `Ecto.NoResultsError` if the Employee does not exist.

  ## Examples

      iex> get_employee!(123)
      %Employee{}

      iex> get_employee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_employee!(id), do: Repo.get!(Employee, id)
  def get_employee(id), do: Repo.get(Employee, id)
  def get_employees_by_user_id(id), do: Employee |> where(user_id: ^id) |> Repo.all()

  def get_employee_setting_by_user_id(user_id) do
    from(es in EmployeeSetting,
      join: e in Employee,
      on: es.employee_id == e.id,
      where: e.user_id == ^user_id
    )
    |> Repo.all()
  end

  def get_employees_by_user_id_of_confirmed_brnach(id) do
    Employee
    |> join(:inner, [emp], b in Branch, on: emp.branch_id == b.id)
    |> where([_, b], b.status_id != "deleted")
    |> where([emp], emp.user_id == ^id)
    |> Repo.all()
  end

  def get_employees_by_branch_id(id) do
    from(e in Employee,
      where:
        e.branch_id == ^id and
          e.employee_status_id not in ["pending_enrollment", "pending_approval", "rejected"]
    )
    |> Repo.all()
  end

  def get_branch_manager_by_manager_id(employee_id) do
    from(e in Employee,
      where: e.id == ^employee_id and e.employee_role_id in ["branch_manager", "owner"]
    )
    |> Repo.one()
  end

  def get_branch_by_employee(employee_id) do
    from(e in Employee, where: e.id == ^employee_id, select: e.branch_id)
    |> Repo.one()
  end

  def get_owner_or_manager_by_user_and_business(user_id, business_id) do
    from(e in Employee,
      join: u in User,
      on: e.user_id == u.id,
      join: b in Branch,
      on: e.branch_id == b.id,
      join: bus in Business,
      on: b.business_id == bus.id,
      where:
        e.user_id == ^user_id and bus.id == ^business_id and
          (e.employee_role_id == "owner" or e.employee_role_id == "branch_manager")
    )
    |> Repo.one()
  end

  def check_branch_owner_or_branch_manager(user_id, branch_id) do
    Employee
    |> where([e], e.branch_id == ^branch_id)
    |> where([e], e.user_id == ^user_id)
    |> where([e], e.employee_role_id in ["branch_manager", "owner"])
    |> Repo.exists?()
  end

  def check_branch_owner_or_branch_manager_by(branch_id) do
    from(e in Employee,
      join: b in Branch,
      on: e.branch_id == b.id,
      where: b.id == ^branch_id and e.employee_role_id in ["owner", "branch_manager"]
    )
    |> Repo.one()
  end

  def get_owner_by_branch_id(branch_id) do
    from(e in Employee,
      join: b in Branch,
      on: e.branch_id == b.id,
      where: b.id == ^branch_id and e.employee_role_id == "owner"
    )
    |> Repo.one()
  end

  def get_by_branch_id(branch_id, employee_role) do
    from(e in Employee,
      join: b in Branch,
      on: e.branch_id == b.id,
      where: b.id == ^branch_id and e.employee_role_id in ^employee_role
    )
    |> Repo.one()
  end

  def get_owner_user_by_branch_id(branch_id) do
    from(u in User,
      join: e in Employee,
      on: e.user_id == u.id,
      join: b in Branch,
      on: e.branch_id == b.id,
      where: b.id == ^branch_id and e.employee_role_id == "owner"
    )
    |> Repo.one()
  end

  def get_employee_by_user(%{employee_id: employee_id, user_id: user_id}) do
    from(e in Employee, where: e.id == ^employee_id and e.user_id == ^user_id)
    |> Repo.one()
  end

  def get_owner_or_manager_by_user_and_branch(user_id, branch_id) do
    from(e in Employee,
      where:
        e.user_id == ^user_id and
          (e.employee_role_id == "owner" or e.employee_role_id == "branch_manager") and
          e.branch_id == ^branch_id
    )
    |> Repo.one()
  end

  def get_owner_by_user_and_branch(user_id, branch_id) do
    from(e in Employee,
      where:
        e.user_id == ^user_id and
          (e.employee_role_id == "owner" or e.employee_role_id == "branch_manager") and
          e.branch_id == ^branch_id,
      limit: 1
    )
    |> Repo.one()
  end

  def get_owner_or_manager_by_user(user_id) do
    from(e in Employee,
      where:
        e.user_id == ^user_id and
          (e.employee_role_id == "owner" or e.employee_role_id == "branch_manager")
    )
    |> Repo.one()
  end

  def get_employee_by_branch_id(user_id, branch_id) do
    from(e in Employee, where: e.user_id == ^user_id and e.branch_id == ^branch_id)
    |> Repo.all()
  end

  def get_employee_by_role_and_branch(ids, role) when is_list(ids) do
    Employee
    |> where([e], e.employee_role_id == ^role and e.branch_id in ^ids)
    |> Repo.all()
  end

  def get_employee_by_role_and_branch(id, role) do
    Employee
    |> where([e], e.employee_role_id == ^role and e.branch_id == ^id)
    |> Repo.all()
  end

  def get_active_employee_by_role_and_branch(branch_id, role) do
    from(e in Employee,
      where:
        e.employee_role_id == ^role and e.branch_id == ^branch_id and
          e.employee_status_id == "active"
    )
    |> Repo.all()
  end

  def get_business_by_employee(employee_id) do
    Repo.one(
      from e in Employee,
        join: b in Branch,
        on: e.branch_id == b.id,
        join: bus in Business,
        on: bus.id == b.business_id,
        where: e.id == ^employee_id,
        select: bus.id
    )
  end

  #  def get_employee_by_status(%{
  #    branch_id: branch_id,
  #    user_id: user_id
  #  }) do
  #     from(e in Employee, where: e.user_id == ^user_id and e.branch_id == ^branch_id)
  #     |> Repo.all()
  #  end

  def get_employees_by(%{
        employee_role_id: _employee_role_id,
        branch_id: branch_id,
        user_id: user_id
      }) do
    from(e in Employee)
    |> where(
      [e],
      e.branch_id == ^branch_id and e.user_id == ^user_id
      #      and e.employee_role_id == ^employee_role_id
    )
    |> Repo.all()
  end

  def get_employees_by_user_and_branch_id(%{
        branch_id: branch_id,
        user_id: user_id
      }) do
    from(e in Employee)
    |> where([e], e.branch_id == ^branch_id and e.user_id == ^user_id)
    |> Repo.all()
  end

  def get_employees_by_branch_service_id(%{branch_service_id: branch_service_id}) do
    from(e in Employee)
    |> where([e], e.branch_service_id == ^branch_service_id)
    |> Repo.all()
  end

  def get_employees_by_branch_id_and_specific_roles(%{
        branch_id: branch_id
      }) do
    from(e in Employee)
    |> where(
      [e],
      e.branch_id == ^branch_id and
        e.employee_status_id == "active" and
        e.employee_role_id not in ["support_manager", "support_associate", "support_trainee"]
    )
    |> Repo.all()
  end

  def get_employee_by_job_id(job_id) do
    from(j in Job,
      join: bs in BranchService,
      on: bs.id == j.branch_service_id or bs.id in j.branch_service_ids,
      join: b in Branch,
      on: bs.branch_id == b.id,
      join: e in Employee,
      on: b.id == e.branch_id,
      select: e.user_id,
      distinct: e.user_id,
      where: j.id == ^job_id
    )
    |> Repo.all()
  end

  @doc """
  Creates a employee.

  ## Examples

      iex> create_employee(%{field: value})
      {:ok, %Employee{}}

      iex> create_employee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_employee(attrs \\ %{}) do
    %Employee{}
    |> Employee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a employee.

  ## Examples

      iex> update_employee(employee, %{field: new_value})
      {:ok, %Employee{}}

      iex> update_employee(employee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_employee(%Employee{} = employee, attrs) do
    employee
    |> Employee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Employee.

  ## Examples

      iex> delete_employee(employee)
      {:ok, %Employee{}}

      iex> delete_employee(employee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employee(%Employee{} = employee) do
    Repo.delete(employee)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking employee changes.

  ## Examples

      iex> change_employee(employee)
      %Ecto.Changeset{source: %Employee{}}

  """
  def change_employee(%Employee{} = employee) do
    Employee.changeset(employee, %{})
  end

  @doc """
  Returns the list of manage_employees.

  ## Examples

      iex> list_manage_employees()
      [%ManageEmployee{}, ...]

  """
  def list_manage_employees do
    Repo.all(ManageEmployee)
  end

  @doc """
  Gets a single manage_employee.

  Raises `Ecto.NoResultsError` if the Manage employee does not exist.

  ## Examples

      iex> get_manage_employee!(123)
      %ManageEmployee{}

      iex> get_manage_employee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_manage_employee!(id), do: Repo.get!(ManageEmployee, id)
  def get_manage_employee(id), do: Repo.get(ManageEmployee, id)

  def get_manage_employee_by(%{employee_id: employee_id, manager_id: manager_id}) do
    Repo.all(
      from me in ManageEmployee,
        where: me.employee_id == ^employee_id and me.manager_id == ^manager_id
    )
  end

  def get_employees_by_manager(manager_id) do
    Repo.all(from me in ManageEmployee, where: me.manager_id == ^manager_id)
  end

  def get_employee_by_manager(manager_id) do
    Repo.all(from me in Employee, where: me.manager_id == ^manager_id)
  end

  @doc """
  Creates a manage_employee.

  ## Examples

      iex> create_manage_employee(%{field: value})
      {:ok, %ManageEmployee{}}

      iex> create_manage_employee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_manage_employee(attrs \\ %{}) do
    %ManageEmployee{}
    |> ManageEmployee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a manage_employee.

  ## Examples

      iex> update_manage_employee(manage_employee, %{field: new_value})
      {:ok, %ManageEmployee{}}

      iex> update_manage_employee(manage_employee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_manage_employee(%ManageEmployee{} = manage_employee, attrs) do
    manage_employee
    |> ManageEmployee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a manage_employee.

  ## Examples

      iex> delete_manage_employee(manage_employee)
      {:ok, %ManageEmployee{}}

      iex> delete_manage_employee(manage_employee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_manage_employee(%ManageEmployee{} = manage_employee) do
    Repo.delete(manage_employee)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking manage_employee changes.

  ## Examples

      iex> change_manage_employee(manage_employee)
      %Ecto.Changeset{source: %ManageEmployee{}}

  """
  def change_manage_employee(%ManageEmployee{} = manage_employee) do
    ManageEmployee.changeset(manage_employee, %{})
  end

  @doc """
  Returns the list of employee_settings.

  ## Examples

      iex> list_employee_settings()
      [%EmployeeSetting{}, ...]

  """
  def list_employee_settings do
    Repo.all(EmployeeSetting)
  end

  @doc """
  Gets a single employee_setting.

  Raises `Ecto.NoResultsError` if the Employee setting does not exist.

  ## Examples

      iex> get_employee_setting!(123)
      %EmployeeSetting{}

      iex> get_employee_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_employee_setting!(id), do: Repo.get!(EmployeeSetting, id)
  def get_employee_setting(id), do: Repo.get(EmployeeSetting, id)

  def get_employee_setting_by(id) do
    Repo.all(from es in EmployeeSetting, where: es.employee_id == ^id)
  end

  @doc """
  Creates a employee_setting.

  ## Examples

      iex> create_employee_setting(%{field: value})
      {:ok, %EmployeeSetting{}}

      iex> create_employee_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_employee_setting(attrs \\ %{}) do
    %EmployeeSetting{}
    |> EmployeeSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a employee_setting.

  ## Examples

      iex> update_employee_setting(employee_setting, %{field: new_value})
      {:ok, %EmployeeSetting{}}

      iex> update_employee_setting(employee_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_employee_setting(%EmployeeSetting{} = employee_setting, attrs) do
    employee_setting
    |> EmployeeSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a employee_setting.

  ## Examples

      iex> delete_employee_setting(employee_setting)
      {:ok, %EmployeeSetting{}}

      iex> delete_employee_setting(employee_setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employee_setting(%EmployeeSetting{} = employee_setting) do
    Repo.delete(employee_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking employee_setting changes.

  ## Examples

      iex> change_employee_setting(employee_setting)
      %Ecto.Changeset{source: %EmployeeSetting{}}

  """
  def change_employee_setting(%EmployeeSetting{} = employee_setting) do
    EmployeeSetting.changeset(employee_setting, %{})
  end
end
