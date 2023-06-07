defmodule CoreWeb.BusinessTypeControllerTest do
  use CoreWeb.ConnCase

  alias Core.BSP

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:business_type) do
    {:ok, business_type} = BSP.create_business_type(@create_attrs)
    business_type
  end

  describe "index" do
    test "lists all business_types", %{conn: conn} do
      conn = get(conn, Routes.business_type_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Business types"
    end
  end

  describe "new business_type" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.business_type_path(conn, :new))
      assert html_response(conn, 200) =~ "New Business type"
    end
  end

  describe "create business_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.business_type_path(conn, :create), business_type: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.business_type_path(conn, :show, id)

      conn = get(conn, Routes.business_type_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Business type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.business_type_path(conn, :create), business_type: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Business type"
    end
  end

  describe "edit business_type" do
    setup [:create_business_type]

    test "renders form for editing chosen business_type", %{
      conn: conn,
      business_type: business_type
    } do
      conn = get(conn, Routes.business_type_path(conn, :edit, business_type))
      assert html_response(conn, 200) =~ "Edit Business type"
    end
  end

  describe "update business_type" do
    setup [:create_business_type]

    test "redirects when data is valid", %{conn: conn, business_type: business_type} do
      conn =
        put(conn, Routes.business_type_path(conn, :update, business_type),
          business_type: @update_attrs
        )

      assert redirected_to(conn) == Routes.business_type_path(conn, :show, business_type)

      conn = get(conn, Routes.business_type_path(conn, :show, business_type))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, business_type: business_type} do
      conn =
        put(conn, Routes.business_type_path(conn, :update, business_type),
          business_type: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Business type"
    end
  end

  describe "delete business_type" do
    setup [:create_business_type]

    test "deletes chosen business_type", %{conn: conn, business_type: business_type} do
      conn = delete(conn, Routes.business_type_path(conn, :delete, business_type))
      assert redirected_to(conn) == Routes.business_type_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.business_type_path(conn, :show, business_type))
      end
    end
  end

  defp create_business_type(_) do
    business_type = fixture(:business_type)
    {:ok, business_type: business_type}
  end
end
