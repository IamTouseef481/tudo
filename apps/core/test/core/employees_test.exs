defmodule Core.EmployeesTest do
  use Core.DataCase

  alias Core.Employees

  describe "employee_roles" do
    alias Core.Schemas.EmployeeRole

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def employee_role_fixture(attrs \\ %{}) do
      {:ok, employee_role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Employees.create_employee_role()

      employee_role
    end

    test "list_employee_roles/0 returns all employee_roles" do
      employee_role = employee_role_fixture()
      assert Employees.list_employee_roles() == [employee_role]
    end

    test "get_employee_role!/1 returns the employee_role with given id" do
      employee_role = employee_role_fixture()
      assert Employees.get_employee_role!(employee_role.id) == employee_role
    end

    test "create_employee_role/1 with valid data creates a employee_role" do
      assert {:ok, %EmployeeRole{} = employee_role} = Employees.create_employee_role(@valid_attrs)
      assert employee_role.name == "some name"
    end

    test "create_employee_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Employees.create_employee_role(@invalid_attrs)
    end

    test "update_employee_role/2 with valid data updates the employee_role" do
      employee_role = employee_role_fixture()

      assert {:ok, %EmployeeRole{} = employee_role} =
               Employees.update_employee_role(employee_role, @update_attrs)

      assert employee_role.name == "some updated name"
    end

    test "update_employee_role/2 with invalid data returns error changeset" do
      employee_role = employee_role_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Employees.update_employee_role(employee_role, @invalid_attrs)

      assert employee_role == Employees.get_employee_role!(employee_role.id)
    end

    test "delete_employee_role/1 deletes the employee_role" do
      employee_role = employee_role_fixture()
      assert {:ok, %EmployeeRole{}} = Employees.delete_employee_role(employee_role)
      assert_raise Ecto.NoResultsError, fn -> Employees.get_employee_role!(employee_role.id) end
    end

    test "change_employee_role/1 returns a employee_role changeset" do
      employee_role = employee_role_fixture()
      assert %Ecto.Changeset{} = Employees.change_employee_role(employee_role)
    end
  end

  describe "employee_statuses" do
    alias Core.Schemas.EmployeeStatus

    @valid_attrs %{name: "some name", slug: "some slug"}
    @update_attrs %{name: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{name: nil, slug: nil}

    def employee_status_fixture(attrs \\ %{}) do
      {:ok, employee_status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Employees.create_employee_status()

      employee_status
    end

    test "list_employee_statuses/0 returns all employee_statuses" do
      employee_status = employee_status_fixture()
      assert Employees.list_employee_statuses() == [employee_status]
    end

    test "get_employee_status!/1 returns the employee_status with given id" do
      employee_status = employee_status_fixture()
      assert Employees.get_employee_status!(employee_status.id) == employee_status
    end

    test "create_employee_status/1 with valid data creates a employee_status" do
      assert {:ok, %EmployeeStatus{} = employee_status} =
               Employees.create_employee_status(@valid_attrs)

      assert employee_status.name == "some name"
      assert employee_status.slug == "some slug"
    end

    test "create_employee_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Employees.create_employee_status(@invalid_attrs)
    end

    test "update_employee_status/2 with valid data updates the employee_status" do
      employee_status = employee_status_fixture()

      assert {:ok, %EmployeeStatus{} = employee_status} =
               Employees.update_employee_status(employee_status, @update_attrs)

      assert employee_status.name == "some updated name"
      assert employee_status.slug == "some updated slug"
    end

    test "update_employee_status/2 with invalid data returns error changeset" do
      employee_status = employee_status_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Employees.update_employee_status(employee_status, @invalid_attrs)

      assert employee_status == Employees.get_employee_status!(employee_status.id)
    end

    test "delete_employee_status/1 deletes the employee_status" do
      employee_status = employee_status_fixture()
      assert {:ok, %EmployeeStatus{}} = Employees.delete_employee_status(employee_status)

      assert_raise Ecto.NoResultsError, fn ->
        Employees.get_employee_status!(employee_status.id)
      end
    end

    test "change_employee_status/1 returns a employee_status changeset" do
      employee_status = employee_status_fixture()
      assert %Ecto.Changeset{} = Employees.change_employee_status(employee_status)
    end
  end

  describe "employee_types" do
    alias Core.Schemas.EmployeeType

    @valid_attrs %{name: "some name", slug: "some slug"}
    @update_attrs %{name: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{name: nil, slug: nil}

    def employee_type_fixture(attrs \\ %{}) do
      {:ok, employee_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Employees.create_employee_type()

      employee_type
    end

    test "list_employee_types/0 returns all employee_types" do
      employee_type = employee_type_fixture()
      assert Employees.list_employee_types() == [employee_type]
    end

    test "get_employee_type!/1 returns the employee_type with given id" do
      employee_type = employee_type_fixture()
      assert Employees.get_employee_type!(employee_type.id) == employee_type
    end

    test "create_employee_type/1 with valid data creates a employee_type" do
      assert {:ok, %EmployeeType{} = employee_type} = Employees.create_employee_type(@valid_attrs)
      assert employee_type.name == "some name"
      assert employee_type.slug == "some slug"
    end

    test "create_employee_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Employees.create_employee_type(@invalid_attrs)
    end

    test "update_employee_type/2 with valid data updates the employee_type" do
      employee_type = employee_type_fixture()

      assert {:ok, %EmployeeType{} = employee_type} =
               Employees.update_employee_type(employee_type, @update_attrs)

      assert employee_type.name == "some updated name"
      assert employee_type.slug == "some updated slug"
    end

    test "update_employee_type/2 with invalid data returns error changeset" do
      employee_type = employee_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Employees.update_employee_type(employee_type, @invalid_attrs)

      assert employee_type == Employees.get_employee_type!(employee_type.id)
    end

    test "delete_employee_type/1 deletes the employee_type" do
      employee_type = employee_type_fixture()
      assert {:ok, %EmployeeType{}} = Employees.delete_employee_type(employee_type)
      assert_raise Ecto.NoResultsError, fn -> Employees.get_employee_type!(employee_type.id) end
    end

    test "change_employee_type/1 returns a employee_type changeset" do
      employee_type = employee_type_fixture()
      assert %Ecto.Changeset{} = Employees.change_employee_type(employee_type)
    end
  end

  describe "shift_schedules" do
    alias Core.Schemas.ShiftSchedule

    @valid_attrs %{
      end_time: ~T[14:00:00],
      name: "some name",
      slug: "some slug",
      started_time: ~T[14:00:00]
    }
    @update_attrs %{
      end_time: ~T[15:01:01],
      name: "some updated name",
      slug: "some updated slug",
      started_time: ~T[15:01:01]
    }
    @invalid_attrs %{end_time: nil, name: nil, slug: nil, started_time: nil}

    def shift_schedule_fixture(attrs \\ %{}) do
      {:ok, shift_schedule} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Employees.create_shift_schedule()

      shift_schedule
    end

    test "list_shift_schedules/0 returns all shift_schedules" do
      shift_schedule = shift_schedule_fixture()
      assert Employees.list_shift_schedules() == [shift_schedule]
    end

    test "get_shift_schedule!/1 returns the shift_schedule with given id" do
      shift_schedule = shift_schedule_fixture()
      assert Employees.get_shift_schedule!(shift_schedule.id) == shift_schedule
    end

    test "create_shift_schedule/1 with valid data creates a shift_schedule" do
      assert {:ok, %ShiftSchedule{} = shift_schedule} =
               Employees.create_shift_schedule(@valid_attrs)

      assert shift_schedule.end_time == ~T[14:00:00]
      assert shift_schedule.name == "some name"
      assert shift_schedule.slug == "some slug"
      assert shift_schedule.started_time == ~T[14:00:00]
    end

    test "create_shift_schedule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Employees.create_shift_schedule(@invalid_attrs)
    end

    test "update_shift_schedule/2 with valid data updates the shift_schedule" do
      shift_schedule = shift_schedule_fixture()

      assert {:ok, %ShiftSchedule{} = shift_schedule} =
               Employees.update_shift_schedule(shift_schedule, @update_attrs)

      assert shift_schedule.end_time == ~T[15:01:01]
      assert shift_schedule.name == "some updated name"
      assert shift_schedule.slug == "some updated slug"
      assert shift_schedule.started_time == ~T[15:01:01]
    end

    test "update_shift_schedule/2 with invalid data returns error changeset" do
      shift_schedule = shift_schedule_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Employees.update_shift_schedule(shift_schedule, @invalid_attrs)

      assert shift_schedule == Employees.get_shift_schedule!(shift_schedule.id)
    end

    test "delete_shift_schedule/1 deletes the shift_schedule" do
      shift_schedule = shift_schedule_fixture()
      assert {:ok, %ShiftSchedule{}} = Employees.delete_shift_schedule(shift_schedule)
      assert_raise Ecto.NoResultsError, fn -> Employees.get_shift_schedule!(shift_schedule.id) end
    end

    test "change_shift_schedule/1 returns a shift_schedule changeset" do
      shift_schedule = shift_schedule_fixture()
      assert %Ecto.Changeset{} = Employees.change_shift_schedule(shift_schedule)
    end
  end

  describe "pay_rates" do
    alias Core.Schemas.PayRate

    @valid_attrs %{details: %{}, name: "some name", slug: "some slug"}
    @update_attrs %{details: %{}, name: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{details: nil, name: nil, slug: nil}

    def pay_rate_fixture(attrs \\ %{}) do
      {:ok, pay_rate} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Employees.create_pay_rate()

      pay_rate
    end

    test "list_pay_rates/0 returns all pay_rates" do
      pay_rate = pay_rate_fixture()
      assert Employees.list_pay_rates() == [pay_rate]
    end

    test "get_pay_rate!/1 returns the pay_rate with given id" do
      pay_rate = pay_rate_fixture()
      assert Employees.get_pay_rate!(pay_rate.id) == pay_rate
    end

    test "create_pay_rate/1 with valid data creates a pay_rate" do
      assert {:ok, %PayRate{} = pay_rate} = Employees.create_pay_rate(@valid_attrs)
      assert pay_rate.details == %{}
      assert pay_rate.name == "some name"
      assert pay_rate.slug == "some slug"
    end

    test "create_pay_rate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Employees.create_pay_rate(@invalid_attrs)
    end

    test "update_pay_rate/2 with valid data updates the pay_rate" do
      pay_rate = pay_rate_fixture()
      assert {:ok, %PayRate{} = pay_rate} = Employees.update_pay_rate(pay_rate, @update_attrs)
      assert pay_rate.details == %{}
      assert pay_rate.name == "some updated name"
      assert pay_rate.slug == "some updated slug"
    end

    test "update_pay_rate/2 with invalid data returns error changeset" do
      pay_rate = pay_rate_fixture()
      assert {:error, %Ecto.Changeset{}} = Employees.update_pay_rate(pay_rate, @invalid_attrs)
      assert pay_rate == Employees.get_pay_rate!(pay_rate.id)
    end

    test "delete_pay_rate/1 deletes the pay_rate" do
      pay_rate = pay_rate_fixture()
      assert {:ok, %PayRate{}} = Employees.delete_pay_rate(pay_rate)
      assert_raise Ecto.NoResultsError, fn -> Employees.get_pay_rate!(pay_rate.id) end
    end

    test "change_pay_rate/1 returns a pay_rate changeset" do
      pay_rate = pay_rate_fixture()
      assert %Ecto.Changeset{} = Employees.change_pay_rate(pay_rate)
    end
  end

  describe "employees" do
    alias Core.Schemas.Employee

    @valid_attrs %{
      allowed_annual_ansence_hrs: 42,
      contract_begin_date: "2010-04-17T14:00:00Z",
      contract_end_date: "2010-04-17T14:00:00Z",
      id_documents: %{},
      pay_scale: 42,
      vehicle_details: %{}
    }
    @update_attrs %{
      allowed_annual_ansence_hrs: 43,
      contract_begin_date: "2011-05-18T15:01:01Z",
      contract_end_date: "2011-05-18T15:01:01Z",
      id_documents: %{},
      pay_scale: 43,
      vehicle_details: %{}
    }
    @invalid_attrs %{
      allowed_annual_ansence_hrs: nil,
      contract_begin_date: nil,
      contract_end_date: nil,
      id_documents: nil,
      pay_scale: nil,
      vehicle_details: nil
    }

    def employee_fixture(attrs \\ %{}) do
      {:ok, employee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Employees.create_employee()

      employee
    end

    test "list_employees/0 returns all employees" do
      employee = employee_fixture()
      assert Employees.list_employees() == [employee]
    end

    test "get_employee!/1 returns the employee with given id" do
      employee = employee_fixture()
      assert Employees.get_employee!(employee.id) == employee
    end

    test "create_employee/1 with valid data creates a employee" do
      assert {:ok, %Employee{} = employee} = Employees.create_employee(@valid_attrs)
      assert employee.allowed_annual_ansence_hrs == 42

      assert employee.contract_begin_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert employee.contract_end_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert employee.id_documents == %{}
      assert employee.pay_scale == 42
      assert employee.vehicle_details == %{}
    end

    test "create_employee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Employees.create_employee(@invalid_attrs)
    end

    test "update_employee/2 with valid data updates the employee" do
      employee = employee_fixture()
      assert {:ok, %Employee{} = employee} = Employees.update_employee(employee, @update_attrs)
      assert employee.allowed_annual_ansence_hrs == 43

      assert employee.contract_begin_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert employee.contract_end_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert employee.id_documents == %{}
      assert employee.pay_scale == 43
      assert employee.vehicle_details == %{}
    end

    test "update_employee/2 with invalid data returns error changeset" do
      employee = employee_fixture()
      assert {:error, %Ecto.Changeset{}} = Employees.update_employee(employee, @invalid_attrs)
      assert employee == Employees.get_employee!(employee.id)
    end

    test "delete_employee/1 deletes the employee" do
      employee = employee_fixture()
      assert {:ok, %Employee{}} = Employees.delete_employee(employee)
      assert_raise Ecto.NoResultsError, fn -> Employees.get_employee!(employee.id) end
    end

    test "change_employee/1 returns a employee changeset" do
      employee = employee_fixture()
      assert %Ecto.Changeset{} = Employees.change_employee(employee)
    end
  end

  describe "manage_employees" do
    alias Core.Schemas.ManageEmployee

    @valid_attrs %{manager_id: 42}
    @update_attrs %{manager_id: 43}
    @invalid_attrs %{manager_id: nil}

    def manage_employee_fixture(attrs \\ %{}) do
      {:ok, manage_employee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Employees.create_manage_employee()

      manage_employee
    end

    test "list_manage_employees/0 returns all manage_employees" do
      manage_employee = manage_employee_fixture()
      assert Employees.list_manage_employees() == [manage_employee]
    end

    test "get_manage_employee!/1 returns the manage_employee with given id" do
      manage_employee = manage_employee_fixture()
      assert Employees.get_manage_employee!(manage_employee.id) == manage_employee
    end

    test "create_manage_employee/1 with valid data creates a manage_employee" do
      assert {:ok, %ManageEmployee{} = manage_employee} =
               Employees.create_manage_employee(@valid_attrs)

      assert manage_employee.manager_id == 42
    end

    test "create_manage_employee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Employees.create_manage_employee(@invalid_attrs)
    end

    test "update_manage_employee/2 with valid data updates the manage_employee" do
      manage_employee = manage_employee_fixture()

      assert {:ok, %ManageEmployee{} = manage_employee} =
               Employees.update_manage_employee(manage_employee, @update_attrs)

      assert manage_employee.manager_id == 43
    end

    test "update_manage_employee/2 with invalid data returns error changeset" do
      manage_employee = manage_employee_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Employees.update_manage_employee(manage_employee, @invalid_attrs)

      assert manage_employee == Employees.get_manage_employee!(manage_employee.id)
    end

    test "delete_manage_employee/1 deletes the manage_employee" do
      manage_employee = manage_employee_fixture()
      assert {:ok, %ManageEmployee{}} = Employees.delete_manage_employee(manage_employee)

      assert_raise Ecto.NoResultsError, fn ->
        Employees.get_manage_employee!(manage_employee.id)
      end
    end

    test "change_manage_employee/1 returns a manage_employee changeset" do
      manage_employee = manage_employee_fixture()
      assert %Ecto.Changeset{} = Employees.change_manage_employee(manage_employee)
    end
  end

  describe "employee_settings" do
    alias Core.Schemas.EmployeeSetting

    @valid_attrs %{
      experience: true,
      family: true,
      insurance: true,
      qualification: true,
      vehicle: true,
      wallet: true
    }
    @update_attrs %{
      experience: false,
      family: false,
      insurance: false,
      qualification: false,
      vehicle: false,
      wallet: false
    }
    @invalid_attrs %{
      experience: nil,
      family: nil,
      insurance: nil,
      qualification: nil,
      vehicle: nil,
      wallet: nil
    }

    def employee_setting_fixture(attrs \\ %{}) do
      {:ok, employee_setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Employees.create_employee_setting()

      employee_setting
    end

    test "list_employee_settings/0 returns all employee_settings" do
      employee_setting = employee_setting_fixture()
      assert Employees.list_employee_settings() == [employee_setting]
    end

    test "get_employee_setting!/1 returns the employee_setting with given id" do
      employee_setting = employee_setting_fixture()
      assert Employees.get_employee_setting!(employee_setting.id) == employee_setting
    end

    test "create_employee_setting/1 with valid data creates a employee_setting" do
      assert {:ok, %EmployeeSetting{} = employee_setting} =
               Employees.create_employee_setting(@valid_attrs)

      assert employee_setting.experience == true
      assert employee_setting.family == true
      assert employee_setting.insurance == true
      assert employee_setting.qualification == true
      assert employee_setting.vehicle == true
      assert employee_setting.wallet == true
    end

    test "create_employee_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Employees.create_employee_setting(@invalid_attrs)
    end

    test "update_employee_setting/2 with valid data updates the employee_setting" do
      employee_setting = employee_setting_fixture()

      assert {:ok, %EmployeeSetting{} = employee_setting} =
               Employees.update_employee_setting(employee_setting, @update_attrs)

      assert employee_setting.experience == false
      assert employee_setting.family == false
      assert employee_setting.insurance == false
      assert employee_setting.qualification == false
      assert employee_setting.vehicle == false
      assert employee_setting.wallet == false
    end

    test "update_employee_setting/2 with invalid data returns error changeset" do
      employee_setting = employee_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Employees.update_employee_setting(employee_setting, @invalid_attrs)

      assert employee_setting == Employees.get_employee_setting!(employee_setting.id)
    end

    test "delete_employee_setting/1 deletes the employee_setting" do
      employee_setting = employee_setting_fixture()
      assert {:ok, %EmployeeSetting{}} = Employees.delete_employee_setting(employee_setting)

      assert_raise Ecto.NoResultsError, fn ->
        Employees.get_employee_setting!(employee_setting.id)
      end
    end

    test "change_employee_setting/1 returns a employee_setting changeset" do
      employee_setting = employee_setting_fixture()
      assert %Ecto.Changeset{} = Employees.change_employee_setting(employee_setting)
    end
  end
end
