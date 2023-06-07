defmodule CoreWeb.ServiceControllerTest do
  use CoreWeb.ConnCase

  alias Core.Services

  @create_attrs %{
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

  def fixture(:service) do
    {:ok, service} = Services.create_service(@create_attrs)
    service
  end

  describe "index" do
    test "lists all services", %{conn: conn} do
      conn = get(conn, Routes.service_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Services"
    end
  end

  describe "new service" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.service_path(conn, :new))
      assert html_response(conn, 200) =~ "New Service"
    end
  end

  describe "create service" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.service_path(conn, :create), service: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.service_path(conn, :show, id)

      conn = get(conn, Routes.service_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Service"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.service_path(conn, :create), service: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Service"
    end
  end

  describe "edit service" do
    setup [:create_service]

    test "renders form for editing chosen service", %{conn: conn, service: service} do
      conn = get(conn, Routes.service_path(conn, :edit, service))
      assert html_response(conn, 200) =~ "Edit Service"
    end
  end

  describe "update service" do
    setup [:create_service]

    test "redirects when data is valid", %{conn: conn, service: service} do
      conn = put(conn, Routes.service_path(conn, :update, service), service: @update_attrs)
      assert redirected_to(conn) == Routes.service_path(conn, :show, service)

      conn = get(conn, Routes.service_path(conn, :show, service))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, service: service} do
      conn = put(conn, Routes.service_path(conn, :update, service), service: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Service"
    end
  end

  describe "delete service" do
    setup [:create_service]

    test "deletes chosen service", %{conn: conn, service: service} do
      conn = delete(conn, Routes.service_path(conn, :delete, service))
      assert redirected_to(conn) == Routes.service_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.service_path(conn, :show, service))
      end
    end
  end

  defp create_service(_) do
    service = fixture(:service)
    {:ok, service: service}
  end
end
