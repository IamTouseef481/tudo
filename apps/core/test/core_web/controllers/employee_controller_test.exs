defmodule CoreWeb.EmployeeControllerTest do
  use CoreWeb.ConnCase

  alias Core.Employees

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:employee_role) do
    {:ok, employee_role} = Employees.create_employee_role(@create_attrs)
    employee_role
  end

  describe "index" do
    test "lists all employee_roles", %{conn: conn} do
      conn = get(conn, Routes.employee_role_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Employee roles"
    end
  end

  describe "new employee_role" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.employee_role_path(conn, :new))
      assert html_response(conn, 200) =~ "New Employee role"
    end
  end

  describe "create employee_role" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.employee_role_path(conn, :create), employee_role: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.employee_role_path(conn, :show, id)

      conn = get(conn, Routes.employee_role_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Employee role"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.employee_role_path(conn, :create), employee_role: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Employee role"
    end
  end

  describe "edit employee_role" do
    setup [:create_employee_role]

    test "renders form for editing chosen employee_role", %{
      conn: conn,
      employee_role: employee_role
    } do
      conn = get(conn, Routes.employee_role_path(conn, :edit, employee_role))
      assert html_response(conn, 200) =~ "Edit Employee role"
    end
  end

  describe "update employee_role" do
    setup [:create_employee_role]

    test "redirects when data is valid", %{conn: conn, employee_role: employee_role} do
      conn =
        put(conn, Routes.employee_role_path(conn, :update, employee_role),
          employee_role: @update_attrs
        )

      assert redirected_to(conn) == Routes.employee_role_path(conn, :show, employee_role)

      conn = get(conn, Routes.employee_role_path(conn, :show, employee_role))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, employee_role: employee_role} do
      conn =
        put(conn, Routes.employee_role_path(conn, :update, employee_role),
          employee_role: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Employee role"
    end
  end

  describe "delete employee_role" do
    setup [:create_employee_role]

    test "deletes chosen employee_role", %{conn: conn, employee_role: employee_role} do
      conn = delete(conn, Routes.employee_role_path(conn, :delete, employee_role))
      assert redirected_to(conn) == Routes.employee_role_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.employee_role_path(conn, :show, employee_role))
      end
    end
  end

  defp create_employee_role(_) do
    employee_role = fixture(:employee_role)
    {:ok, employee_role: employee_role}
  end
end
