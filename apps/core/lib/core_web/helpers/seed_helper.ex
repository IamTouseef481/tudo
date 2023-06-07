defmodule CoreWeb.Helpers.SeedHelper do
  @moduledoc false

  @doc false
  defmacro __using__(_) do
    quote do
      use Ecto.Migration

      def import_from_csv(
            csv_path,
            callback,
            should_convert_empty_to_nil \\ true,
            base_path \\ nil
          ) do
        base_path =
          if base_path == nil,
            do: Application.get_env(:core, :repo)[:seed_base_path],
            else: base_path

        (csv_path <> ".csv")
        |> Path.expand(base_path)
        |> File.stream!()
        |> CSV.decode!(headers: true)
        |> Stream.each(fn row ->
          row
          |> map_escap_sql(should_convert_empty_to_nil)
          |> callback.()
        end)
        |> Stream.run()
      end

      def map_escap_sql(map, should_convert_empty_to_nil) do
        for {key, value} <- map, into: %{} do
          case value do
            "null" ->
              {key, value}

            "" ->
              if should_convert_empty_to_nil do
                {key, "null"}
              else
                value =
                  value
                  |> String.replace("'", "''")

                {key, ~s('#{value}')}
              end

            _ ->
              value =
                value
                |> String.replace("'", "''")

              {key, ~s('#{value}')}
          end
        end
      end

      def map_to_table(map, table) do
        keys =
          map
          |> then(fn x ->
            case table do
              "raw_businesses" -> x |> Map.put("inserted_at", "") |> Map.put("updated_at", "")
              _ -> x
            end
          end)
          |> Map.keys()
          |> Enum.join(~s(", "))

        values =
          map
          |> then(fn x ->
            case table do
              "raw_businesses" ->
                case x["location"] do
                  "''" ->
                    Map.put(x, "location", "'#{%Geo.Point{}}'") |> timestamp

                  value ->
                    map =
                      Regex.named_captures(
                        ~r/\'\((?<lat>\-*\d+\.*\d+),(?<long>\s\-*\d+\.*\d+)\)\'\z/,
                        value
                      )

                    location = %Geo.Point{
                      coordinates:
                        {map["long"] |> String.to_float(),
                         map["lat"] |> String.trim() |> String.to_float()},
                      srid: 4326
                    }

                    Map.put(x, "location", "'#{location}'") |> timestamp
                end

              _ ->
                x
            end
          end)
          |> Map.values()
          |> Enum.join(", ")

        Ecto.Migration.execute("INSERT INTO #{table} (\"#{keys}\") values (#{values})")
      end

      def reset_id_seq(table, id \\ "id") do
        Ecto.Migration.execute(
          "SELECT setval('#{table}_#{id}_seq', (SELECT MAX(#{id}) from #{table}));"
        )
      end

      def location_struct(%{lat: lat, long: long}) do
        %Geo.Point{
          coordinates: {long, lat},
          srid: 4326
        }
      end

      def timestamp(map) do
        map
        |> Map.put("inserted_at", "'#{DateTime.utc_now()}'")
        |> Map.put("updated_at", "'#{DateTime.utc_now()}'")
      end
    end
  end
end
