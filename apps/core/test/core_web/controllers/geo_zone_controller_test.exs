defmodule CoreWeb.GeoZoneControllerTest do
  use CoreWeb.ConnCase

  alias Core.GeoZones

  @create_attrs %{
    coordinates: "some coordinates",
    description: "some description",
    slug: "some slug",
    title: "some title"
  }
  @update_attrs %{
    coordinates: "some updated coordinates",
    description: "some updated description",
    slug: "some updated slug",
    title: "some updated title"
  }
  @invalid_attrs %{coordinates: nil, description: nil, slug: nil, title: nil}

  def fixture(:geo_zone) do
    {:ok, geo_zone} = GeoZones.create_geo_zone(@create_attrs)
    geo_zone
  end

  describe "index" do
    test "lists all geo_zones", %{conn: conn} do
      conn = get(conn, Routes.geo_zone_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Geo zones"
    end
  end

  describe "new geo_zone" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.geo_zone_path(conn, :new))
      assert html_response(conn, 200) =~ "New Geo zone"
    end
  end

  describe "create geo_zone" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.geo_zone_path(conn, :create), geo_zone: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.geo_zone_path(conn, :show, id)

      conn = get(conn, Routes.geo_zone_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Geo zone"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.geo_zone_path(conn, :create), geo_zone: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Geo zone"
    end
  end

  describe "edit geo_zone" do
    setup [:create_geo_zone]

    test "renders form for editing chosen geo_zone", %{conn: conn, geo_zone: geo_zone} do
      conn = get(conn, Routes.geo_zone_path(conn, :edit, geo_zone))
      assert html_response(conn, 200) =~ "Edit Geo zone"
    end
  end

  describe "update geo_zone" do
    setup [:create_geo_zone]

    test "redirects when data is valid", %{conn: conn, geo_zone: geo_zone} do
      conn = put(conn, Routes.geo_zone_path(conn, :update, geo_zone), geo_zone: @update_attrs)
      assert redirected_to(conn) == Routes.geo_zone_path(conn, :show, geo_zone)

      conn = get(conn, Routes.geo_zone_path(conn, :show, geo_zone))
      assert html_response(conn, 200) =~ "some updated coordinates"
    end

    test "renders errors when data is invalid", %{conn: conn, geo_zone: geo_zone} do
      conn = put(conn, Routes.geo_zone_path(conn, :update, geo_zone), geo_zone: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Geo zone"
    end
  end

  describe "delete geo_zone" do
    setup [:create_geo_zone]

    test "deletes chosen geo_zone", %{conn: conn, geo_zone: geo_zone} do
      conn = delete(conn, Routes.geo_zone_path(conn, :delete, geo_zone))
      assert redirected_to(conn) == Routes.geo_zone_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.geo_zone_path(conn, :show, geo_zone))
      end
    end
  end

  defp create_geo_zone(_) do
    geo_zone = fixture(:geo_zone)
    {:ok, geo_zone: geo_zone}
  end
end
