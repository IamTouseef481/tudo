defmodule Core.GeoZonesTest do
  use Core.DataCase

  alias Core.GeoZones

  describe "geo_zones" do
    alias Core.Schemas.GeoZone

    @valid_attrs %{
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

    def geo_zone_fixture(attrs \\ %{}) do
      {:ok, geo_zone} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GeoZones.create_geo_zone()

      geo_zone
    end

    test "list_geo_zones/0 returns all geo_zones" do
      geo_zone = geo_zone_fixture()
      assert GeoZones.list_geo_zones() == [geo_zone]
    end

    test "get_geo_zone!/1 returns the geo_zone with given id" do
      geo_zone = geo_zone_fixture()
      assert GeoZones.get_geo_zone!(geo_zone.id) == geo_zone
    end

    test "create_geo_zone/1 with valid data creates a geo_zone" do
      assert {:ok, %GeoZone{} = geo_zone} = GeoZones.create_geo_zone(@valid_attrs)
      assert geo_zone.coordinates == "some coordinates"
      assert geo_zone.description == "some description"
      assert geo_zone.slug == "some slug"
      assert geo_zone.title == "some title"
    end

    test "create_geo_zone/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GeoZones.create_geo_zone(@invalid_attrs)
    end

    test "update_geo_zone/2 with valid data updates the geo_zone" do
      geo_zone = geo_zone_fixture()
      assert {:ok, %GeoZone{} = geo_zone} = GeoZones.update_geo_zone(geo_zone, @update_attrs)
      assert geo_zone.coordinates == "some updated coordinates"
      assert geo_zone.description == "some updated description"
      assert geo_zone.slug == "some updated slug"
      assert geo_zone.title == "some updated title"
    end

    test "update_geo_zone/2 with invalid data returns error changeset" do
      geo_zone = geo_zone_fixture()
      assert {:error, %Ecto.Changeset{}} = GeoZones.update_geo_zone(geo_zone, @invalid_attrs)
      assert geo_zone == GeoZones.get_geo_zone!(geo_zone.id)
    end

    test "delete_geo_zone/1 deletes the geo_zone" do
      geo_zone = geo_zone_fixture()
      assert {:ok, %GeoZone{}} = GeoZones.delete_geo_zone(geo_zone)
      assert_raise Ecto.NoResultsError, fn -> GeoZones.get_geo_zone!(geo_zone.id) end
    end

    test "change_geo_zone/1 returns a geo_zone changeset" do
      geo_zone = geo_zone_fixture()
      assert %Ecto.Changeset{} = GeoZones.change_geo_zone(geo_zone)
    end
  end
end
