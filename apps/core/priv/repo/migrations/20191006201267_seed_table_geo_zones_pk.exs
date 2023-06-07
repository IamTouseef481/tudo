defmodule Core.Repo.Migrations.SeedTable.System.Zone do
  @moduledoc false
  use Ecto.Migration
  import SweetXml
  require Logger

  @seeder "apps/core/priv/repo/seeds/20191006201268_seed_table_geo_zones_pk.kml"

  def up do
    case File.read(@seeder) do
      {:ok, doc} ->
        doc
        |> xpath(
          ~x"//Document/Folder/Placemark"l,
          name:
            ~x"./name/text()"
            |> transform_by(&to_string/1),
          color:
            ~x"./styleUrl/text()"
            |> transform_by(&prepare_color/1),
          coordinates:
            ~x"./Polygon/outerBoundaryIs/LinearRing/coordinates/text()"
            |> transform_by(&prepare_coordinates/1)
        )
        |> Enum.map(&handle_record/1)

      {:error, reason} ->
        Logger.error("""
        #{__MODULE__}:#{__ENV__.line}
        #{inspect(reason, pretty: true)}
        """)

        raise reason
    end
  end

  def handle_record(record) do
    # supporting = "000000" == record.color
    # _status = if supporting, do: 1, else: 2

    execute("INSERT INTO geo_zones
            (title, slug, status_id, description, city_id, state_id, country_id, coordinates) VALUES (
            '#{record.name}', '#{String.replace(record.name, " ", "-")}', 'active', '', null, null , 4,
            st_geomfromtext('SRID=4326;POLYGON(( #{record.coordinates} ))'));")
  end

  def prepare_color(styleUrl) do
    styleUrl
    |> to_string()
    |> String.slice(6..11)
  end

  def prepare_coordinates(coordinates) do
    coordinates
    |> to_string()
    |> String.split(~r(\s+), trim: true)
    |> Enum.map(&prepare_coordinate/1)
    |> Enum.join(", ")
  end

  def prepare_coordinate(coordinate) do
    coordinate
    |> String.split(",")
    |> Enum.reverse_slice(0, 2)
    |> Enum.filter(fn y ->
      y != "0"
    end)
    |> Enum.map(fn y ->
      {parsed, _} = Float.parse(y)
      parsed
    end)
    |> Enum.join(" ")
  end

  def down do
  end
end
