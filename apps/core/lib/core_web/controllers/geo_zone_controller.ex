defmodule CoreWeb.Controllers.GeoZoneController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.GeoZones
  alias Core.Schemas.GeoZone

  def get_zones_by_country(input) do
    case GeoZones.get_geo_zone_by_country_id(input) do
      [] -> {:ok, []}
      zones -> {:ok, Enum.map(zones, &add_geo(&1))}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, unable to fetch Geo Zones!"],
        __ENV__.line
      )
  end

  def index(conn, _params) do
    geo_zones = GeoZones.list_geo_zones()
    render(conn, "index.html", geo_zones: geo_zones)
  end

  def new(conn, _params) do
    changeset = GeoZones.change_geo_zone(%GeoZone{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"geo_zone" => geo_zone_params}) do
    case GeoZones.create_geo_zone(geo_zone_params) do
      {:ok, _geo_zone} ->
        conn
        |> put_flash(:info, "Geo zone created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    geo_zone = GeoZones.get_geo_zone!(id)
    render(conn, "show.html", geo_zone: geo_zone)
  end

  def edit(conn, %{"id" => id}) do
    geo_zone = GeoZones.get_geo_zone!(id)
    changeset = GeoZones.change_geo_zone(geo_zone)
    render(conn, "edit.html", geo_zone: geo_zone, changeset: changeset)
  end

  def update(conn, %{"id" => id, "geo_zone" => geo_zone_params}) do
    geo_zone = GeoZones.get_geo_zone!(id)

    case GeoZones.update_geo_zone(geo_zone, geo_zone_params) do
      {:ok, _geo_zone} ->
        conn
        |> put_flash(:info, "Geo zone updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", geo_zone: geo_zone, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    geo_zone = GeoZones.get_geo_zone!(id)
    {:ok, _geo_zone} = GeoZones.delete_geo_zone(geo_zone)

    conn
    |> put_flash(:info, "Geo zone deleted successfully.")
  end
end
