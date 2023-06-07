defmodule Core.ServicesTest do
  use Core.DataCase

  alias Core.Services

  describe "services" do
    alias Core.Schemas.Service

    @valid_attrs %{
      name: "some name",
      service_category: "some service_category",
      service_group_id: "some service_group_id"
    }
    @update_attrs %{
      name: "some updated name",
      service_category: "some updated service_category",
      service_group_id: "some updated service_group_id"
    }
    @invalid_attrs %{name: nil, service_category: nil, service_group_id: nil}

    def service_fixture(attrs \\ %{}) do
      {:ok, service} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Services.create_service()

      service
    end

    test "list_services/0 returns all services" do
      service = service_fixture()
      assert Services.list_services() == [service]
    end

    test "get_service!/1 returns the service with given id" do
      service = service_fixture()
      assert Services.get_service!(service.id) == service
    end

    test "create_service/1 with valid data creates a service" do
      assert {:ok, %Service{} = service} = Services.create_service(@valid_attrs)
      assert service.name == "some name"
      assert service.service_category == "some service_category"
      assert service.service_group_id == "some service_group_id"
    end

    test "create_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Services.create_service(@invalid_attrs)
    end

    test "update_service/2 with valid data updates the service" do
      service = service_fixture()
      assert {:ok, %Service{} = service} = Services.update_service(service, @update_attrs)
      assert service.name == "some updated name"
      assert service.service_category == "some updated service_category"
      assert service.service_group_id == "some updated service_group_id"
    end

    test "update_service/2 with invalid data returns error changeset" do
      service = service_fixture()
      assert {:error, %Ecto.Changeset{}} = Services.update_service(service, @invalid_attrs)
      assert service == Services.get_service!(service.id)
    end

    test "delete_service/1 deletes the service" do
      service = service_fixture()
      assert {:ok, %Service{}} = Services.delete_service(service)
      assert_raise Ecto.NoResultsError, fn -> Services.get_service!(service.id) end
    end

    test "change_service/1 returns a service changeset" do
      service = service_fixture()
      assert %Ecto.Changeset{} = Services.change_service(service)
    end
  end

  describe "service_groups" do
    alias Core.Schemas.ServiceGroup

    @valid_attrs %{is_active: "some is_active", name: "some name"}
    @update_attrs %{is_active: "some updated is_active", name: "some updated name"}
    @invalid_attrs %{is_active: nil, name: nil}

    def service_group_fixture(attrs \\ %{}) do
      {:ok, service_group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Services.create_service_group()

      service_group
    end

    test "list_service_groups/0 returns all service_groups" do
      service_group = service_group_fixture()
      assert Services.list_service_groups() == [service_group]
    end

    test "get_service_group!/1 returns the service_group with given id" do
      service_group = service_group_fixture()
      assert Services.get_service_group!(service_group.id) == service_group
    end

    test "create_service_group/1 with valid data creates a service_group" do
      assert {:ok, %ServiceGroup{} = service_group} = Services.create_service_group(@valid_attrs)
      assert service_group.is_active == "some is_active"
      assert service_group.name == "some name"
    end

    test "create_service_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Services.create_service_group(@invalid_attrs)
    end

    test "update_service_group/2 with valid data updates the service_group" do
      service_group = service_group_fixture()

      assert {:ok, %ServiceGroup{} = service_group} =
               Services.update_service_group(service_group, @update_attrs)

      assert service_group.is_active == "some updated is_active"
      assert service_group.name == "some updated name"
    end

    test "update_service_group/2 with invalid data returns error changeset" do
      service_group = service_group_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Services.update_service_group(service_group, @invalid_attrs)

      assert service_group == Services.get_service_group!(service_group.id)
    end

    test "delete_service_group/1 deletes the service_group" do
      service_group = service_group_fixture()
      assert {:ok, %ServiceGroup{}} = Services.delete_service_group(service_group)
      assert_raise Ecto.NoResultsError, fn -> Services.get_service_group!(service_group.id) end
    end

    test "change_service_group/1 returns a service_group changeset" do
      service_group = service_group_fixture()
      assert %Ecto.Changeset{} = Services.change_service_group(service_group)
    end
  end

  describe "country_services" do
    alias Core.Schemas.CountryService

    @valid_attrs %{is_active: true}
    @update_attrs %{is_active: false}
    @invalid_attrs %{is_active: nil}

    def country_service_fixture(attrs \\ %{}) do
      {:ok, country_service} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Services.create_country_service()

      country_service
    end

    test "list_country_services/0 returns all country_services" do
      country_service = country_service_fixture()
      assert Services.list_country_services() == [country_service]
    end

    test "get_country_service!/1 returns the country_service with given id" do
      country_service = country_service_fixture()
      assert Services.get_country_service!(country_service.id) == country_service
    end

    test "create_country_service/1 with valid data creates a country_service" do
      assert {:ok, %CountryService{} = country_service} =
               Services.create_country_service(@valid_attrs)

      assert country_service.is_active == true
    end

    test "create_country_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Services.create_country_service(@invalid_attrs)
    end

    test "update_country_service/2 with valid data updates the country_service" do
      country_service = country_service_fixture()

      assert {:ok, %CountryService{} = country_service} =
               Services.update_country_service(country_service, @update_attrs)

      assert country_service.is_active == false
    end

    test "update_country_service/2 with invalid data returns error changeset" do
      country_service = country_service_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Services.update_country_service(country_service, @invalid_attrs)

      assert country_service == Services.get_country_service!(country_service.id)
    end

    test "delete_country_service/1 deletes the country_service" do
      country_service = country_service_fixture()
      assert {:ok, %CountryService{}} = Services.delete_country_service(country_service)

      assert_raise Ecto.NoResultsError, fn ->
        Services.get_country_service!(country_service.id)
      end
    end

    test "change_country_service/1 returns a country_service changeset" do
      country_service = country_service_fixture()
      assert %Ecto.Changeset{} = Services.change_country_service(country_service)
    end
  end

  describe "branch_services" do
    alias Core.Schemas.BranchService

    @valid_attrs %{is_active: true}
    @update_attrs %{is_active: false}
    @invalid_attrs %{is_active: nil}

    def branch_service_fixture(attrs \\ %{}) do
      {:ok, branch_service} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Services.create_branch_service()

      branch_service
    end

    test "list_branch_services/0 returns all branch_services" do
      branch_service = branch_service_fixture()
      assert Services.list_branch_services() == [branch_service]
    end

    test "get_branch_service!/1 returns the branch_service with given id" do
      branch_service = branch_service_fixture()
      assert Services.get_branch_service!(branch_service.id) == branch_service
    end

    test "create_branch_service/1 with valid data creates a branch_service" do
      assert {:ok, %BranchService{} = branch_service} =
               Services.create_branch_service(@valid_attrs)

      assert branch_service.is_active == true
    end

    test "create_branch_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Services.create_branch_service(@invalid_attrs)
    end

    test "update_branch_service/2 with valid data updates the branch_service" do
      branch_service = branch_service_fixture()

      assert {:ok, %BranchService{} = branch_service} =
               Services.update_branch_service(branch_service, @update_attrs)

      assert branch_service.is_active == false
    end

    test "update_branch_service/2 with invalid data returns error changeset" do
      branch_service = branch_service_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Services.update_branch_service(branch_service, @invalid_attrs)

      assert branch_service == Services.get_branch_service!(branch_service.id)
    end

    test "delete_branch_service/1 deletes the branch_service" do
      branch_service = branch_service_fixture()
      assert {:ok, %BranchService{}} = Services.delete_branch_service(branch_service)
      assert_raise Ecto.NoResultsError, fn -> Services.get_branch_service!(branch_service.id) end
    end

    test "change_branch_service/1 returns a branch_service changeset" do
      branch_service = branch_service_fixture()
      assert %Ecto.Changeset{} = Services.change_branch_service(branch_service)
    end
  end

  describe "employee_services" do
    alias Core.Schemas.EmployeeService

    @valid_attrs %{end_date: "2010-04-17T14:00:00Z", start_date: "2010-04-17T14:00:00Z"}
    @update_attrs %{end_date: "2011-05-18T15:01:01Z", start_date: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{end_date: nil, start_date: nil}

    def employee_service_fixture(attrs \\ %{}) do
      {:ok, employee_service} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Services.create_employee_service()

      employee_service
    end

    test "list_employee_services/0 returns all employee_services" do
      employee_service = employee_service_fixture()
      assert Services.list_employee_services() == [employee_service]
    end

    test "get_employee_service!/1 returns the employee_service with given id" do
      employee_service = employee_service_fixture()
      assert Services.get_employee_service!(employee_service.id) == employee_service
    end

    test "create_employee_service/1 with valid data creates a employee_service" do
      assert {:ok, %EmployeeService{} = employee_service} =
               Services.create_employee_service(@valid_attrs)

      assert employee_service.end_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert employee_service.start_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_employee_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Services.create_employee_service(@invalid_attrs)
    end

    test "update_employee_service/2 with valid data updates the employee_service" do
      employee_service = employee_service_fixture()

      assert {:ok, %EmployeeService{} = employee_service} =
               Services.update_employee_service(employee_service, @update_attrs)

      assert employee_service.end_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert employee_service.start_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_employee_service/2 with invalid data returns error changeset" do
      employee_service = employee_service_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Services.update_employee_service(employee_service, @invalid_attrs)

      assert employee_service == Services.get_employee_service!(employee_service.id)
    end

    test "delete_employee_service/1 deletes the employee_service" do
      employee_service = employee_service_fixture()
      assert {:ok, %EmployeeService{}} = Services.delete_employee_service(employee_service)

      assert_raise Ecto.NoResultsError, fn ->
        Services.get_employee_service!(employee_service.id)
      end
    end

    test "change_employee_service/1 returns a employee_service changeset" do
      employee_service = employee_service_fixture()
      assert %Ecto.Changeset{} = Services.change_employee_service(employee_service)
    end
  end

  describe "service_types" do
    alias Core.Schemas.ServiceType

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def service_type_fixture(attrs \\ %{}) do
      {:ok, service_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Services.create_service_type()

      service_type
    end

    test "list_service_types/0 returns all service_types" do
      service_type = service_type_fixture()
      assert Services.list_service_types() == [service_type]
    end

    test "get_service_type!/1 returns the service_type with given id" do
      service_type = service_type_fixture()
      assert Services.get_service_type!(service_type.id) == service_type
    end

    test "create_service_type/1 with valid data creates a service_type" do
      assert {:ok, %ServiceType{} = service_type} = Services.create_service_type(@valid_attrs)
      assert service_type.description == "some description"
      assert service_type.name == "some name"
    end

    test "create_service_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Services.create_service_type(@invalid_attrs)
    end

    test "update_service_type/2 with valid data updates the service_type" do
      service_type = service_type_fixture()

      assert {:ok, %ServiceType{} = service_type} =
               Services.update_service_type(service_type, @update_attrs)

      assert service_type.description == "some updated description"
      assert service_type.name == "some updated name"
    end

    test "update_service_type/2 with invalid data returns error changeset" do
      service_type = service_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Services.update_service_type(service_type, @invalid_attrs)

      assert service_type == Services.get_service_type!(service_type.id)
    end

    test "delete_service_type/1 deletes the service_type" do
      service_type = service_type_fixture()
      assert {:ok, %ServiceType{}} = Services.delete_service_type(service_type)
      assert_raise Ecto.NoResultsError, fn -> Services.get_service_type!(service_type.id) end
    end

    test "change_service_type/1 returns a service_type changeset" do
      service_type = service_type_fixture()
      assert %Ecto.Changeset{} = Services.change_service_type(service_type)
    end
  end

  describe "service_statuses" do
    alias Core.Schemas.ServiceStatus

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def service_status_fixture(attrs \\ %{}) do
      {:ok, service_status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Services.create_service_status()

      service_status
    end

    test "list_service_statuses/0 returns all service_statuses" do
      service_status = service_status_fixture()
      assert Services.list_service_statuses() == [service_status]
    end

    test "get_service_status!/1 returns the service_status with given id" do
      service_status = service_status_fixture()
      assert Services.get_service_status!(service_status.id) == service_status
    end

    test "create_service_status/1 with valid data creates a service_status" do
      assert {:ok, %ServiceStatus{} = service_status} =
               Services.create_service_status(@valid_attrs)

      assert service_status.description == "some description"
      assert service_status.id == "some id"
    end

    test "create_service_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Services.create_service_status(@invalid_attrs)
    end

    test "update_service_status/2 with valid data updates the service_status" do
      service_status = service_status_fixture()

      assert {:ok, %ServiceStatus{} = service_status} =
               Services.update_service_status(service_status, @update_attrs)

      assert service_status.description == "some updated description"
      assert service_status.id == "some updated id"
    end

    test "update_service_status/2 with invalid data returns error changeset" do
      service_status = service_status_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Services.update_service_status(service_status, @invalid_attrs)

      assert service_status == Services.get_service_status!(service_status.id)
    end

    test "delete_service_status/1 deletes the service_status" do
      service_status = service_status_fixture()
      assert {:ok, %ServiceStatus{}} = Services.delete_service_status(service_status)
      assert_raise Ecto.NoResultsError, fn -> Services.get_service_status!(service_status.id) end
    end

    test "change_service_status/1 returns a service_status changeset" do
      service_status = service_status_fixture()
      assert %Ecto.Changeset{} = Services.change_service_status(service_status)
    end
  end

  describe "service_settings" do
    alias Core.Schemas.ServiceSetting

    @valid_attrs %{exta_params: %{}}
    @update_attrs %{exta_params: %{}}
    @invalid_attrs %{exta_params: nil}

    def service_setting_fixture(attrs \\ %{}) do
      {:ok, service_setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Services.create_service_setting()

      service_setting
    end

    test "list_service_settings/0 returns all service_settings" do
      service_setting = service_setting_fixture()
      assert Services.list_service_settings() == [service_setting]
    end

    test "get_service_setting!/1 returns the service_setting with given id" do
      service_setting = service_setting_fixture()
      assert Services.get_service_setting!(service_setting.id) == service_setting
    end

    test "create_service_setting/1 with valid data creates a service_setting" do
      assert {:ok, %ServiceSetting{} = service_setting} =
               Services.create_service_setting(@valid_attrs)

      assert service_setting.exta_params == %{}
    end

    test "create_service_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Services.create_service_setting(@invalid_attrs)
    end

    test "update_service_setting/2 with valid data updates the service_setting" do
      service_setting = service_setting_fixture()

      assert {:ok, %ServiceSetting{} = service_setting} =
               Services.update_service_setting(service_setting, @update_attrs)

      assert service_setting.exta_params == %{}
    end

    test "update_service_setting/2 with invalid data returns error changeset" do
      service_setting = service_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Services.update_service_setting(service_setting, @invalid_attrs)

      assert service_setting == Services.get_service_setting!(service_setting.id)
    end

    test "delete_service_setting/1 deletes the service_setting" do
      service_setting = service_setting_fixture()
      assert {:ok, %ServiceSetting{}} = Services.delete_service_setting(service_setting)

      assert_raise Ecto.NoResultsError, fn ->
        Services.get_service_setting!(service_setting.id)
      end
    end

    test "change_service_setting/1 returns a service_setting changeset" do
      service_setting = service_setting_fixture()
      assert %Ecto.Changeset{} = Services.change_service_setting(service_setting)
    end
  end
end
