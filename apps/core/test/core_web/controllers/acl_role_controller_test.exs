defmodule CoreWeb.AclRoleControllerTest do
  use CoreWeb.ConnCase

  alias Core.Acl

  @create_attrs %{parent: "some parent", role: "some role"}
  @update_attrs %{parent: "some updated parent", role: "some updated role"}
  @invalid_attrs %{parent: nil, role: nil}

  def fixture(:acl_role) do
    {:ok, acl_role} = Acl.create_acl_role(@create_attrs)
    acl_role
  end

  describe "index" do
    test "lists all acl_roles", %{conn: conn} do
      conn = get(conn, Routes.acl_role_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Acl roles"
    end
  end

  describe "new acl_role" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.acl_role_path(conn, :new))
      assert html_response(conn, 200) =~ "New Acl role"
    end
  end

  describe "create acl_role" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.acl_role_path(conn, :create), acl_role: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.acl_role_path(conn, :show, id)

      conn = get(conn, Routes.acl_role_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Acl role"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.acl_role_path(conn, :create), acl_role: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Acl role"
    end
  end

  describe "edit acl_role" do
    setup [:create_acl_role]

    test "renders form for editing chosen acl_role", %{conn: conn, acl_role: acl_role} do
      conn = get(conn, Routes.acl_role_path(conn, :edit, acl_role))
      assert html_response(conn, 200) =~ "Edit Acl role"
    end
  end

  describe "update acl_role" do
    setup [:create_acl_role]

    test "redirects when data is valid", %{conn: conn, acl_role: acl_role} do
      conn = put(conn, Routes.acl_role_path(conn, :update, acl_role), acl_role: @update_attrs)
      assert redirected_to(conn) == Routes.acl_role_path(conn, :show, acl_role)

      conn = get(conn, Routes.acl_role_path(conn, :show, acl_role))
      assert html_response(conn, 200) =~ "some updated parent"
    end

    test "renders errors when data is invalid", %{conn: conn, acl_role: acl_role} do
      conn = put(conn, Routes.acl_role_path(conn, :update, acl_role), acl_role: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Acl role"
    end
  end

  describe "delete acl_role" do
    setup [:create_acl_role]

    test "deletes chosen acl_role", %{conn: conn, acl_role: acl_role} do
      conn = delete(conn, Routes.acl_role_path(conn, :delete, acl_role))
      assert redirected_to(conn) == Routes.acl_role_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.acl_role_path(conn, :show, acl_role))
      end
    end
  end

  defp create_acl_role(_) do
    acl_role = fixture(:acl_role)
    {:ok, acl_role: acl_role}
  end
end
