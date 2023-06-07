defmodule CoreWeb.DynamicFieldControllerTest do
  use CoreWeb.ConnCase

  alias Core.Dynamics

  @create_attrs %{fields: %{}, is_active: true}
  @update_attrs %{fields: %{}, is_active: false}
  @invalid_attrs %{fields: nil, is_active: nil}

  def fixture(:dynamic_field) do
    {:ok, dynamic_field} = Dynamics.create_dynamic_field(@create_attrs)
    dynamic_field
  end

  describe "index" do
    test "lists all dynamic_fields", %{conn: conn} do
      conn = get(conn, Routes.dynamic_field_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Dynamic fields"
    end
  end

  describe "new dynamic_field" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.dynamic_field_path(conn, :new))
      assert html_response(conn, 200) =~ "New Dynamic field"
    end
  end

  describe "create dynamic_field" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.dynamic_field_path(conn, :create), dynamic_field: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.dynamic_field_path(conn, :show, id)

      conn = get(conn, Routes.dynamic_field_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Dynamic field"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.dynamic_field_path(conn, :create), dynamic_field: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Dynamic field"
    end
  end

  describe "edit dynamic_field" do
    setup [:create_dynamic_field]

    test "renders form for editing chosen dynamic_field", %{
      conn: conn,
      dynamic_field: dynamic_field
    } do
      conn = get(conn, Routes.dynamic_field_path(conn, :edit, dynamic_field))
      assert html_response(conn, 200) =~ "Edit Dynamic field"
    end
  end

  describe "update dynamic_field" do
    setup [:create_dynamic_field]

    test "redirects when data is valid", %{conn: conn, dynamic_field: dynamic_field} do
      conn =
        put(conn, Routes.dynamic_field_path(conn, :update, dynamic_field),
          dynamic_field: @update_attrs
        )

      assert redirected_to(conn) == Routes.dynamic_field_path(conn, :show, dynamic_field)

      conn = get(conn, Routes.dynamic_field_path(conn, :show, dynamic_field))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, dynamic_field: dynamic_field} do
      conn =
        put(conn, Routes.dynamic_field_path(conn, :update, dynamic_field),
          dynamic_field: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Dynamic field"
    end
  end

  describe "delete dynamic_field" do
    setup [:create_dynamic_field]

    test "deletes chosen dynamic_field", %{conn: conn, dynamic_field: dynamic_field} do
      conn = delete(conn, Routes.dynamic_field_path(conn, :delete, dynamic_field))
      assert redirected_to(conn) == Routes.dynamic_field_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.dynamic_field_path(conn, :show, dynamic_field))
      end
    end
  end

  defp create_dynamic_field(_) do
    dynamic_field = fixture(:dynamic_field)
    {:ok, dynamic_field: dynamic_field}
  end
end
