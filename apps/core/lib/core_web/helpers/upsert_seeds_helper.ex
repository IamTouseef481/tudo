defmodule CoreWeb.Helpers.UpsertSeedsHelper do
  @moduledoc false
  alias Core.Context

  alias Core.Schemas.{
    Countries,
    CountryService,
    DynamicBridgeScreensGroup,
    DynamicField,
    DynamicGroup,
    DynamicScreen,
    Service,
    ServiceGroup,
    ServiceSetting
  }

  require Logger

  defmacro __using__(_) do
    quote do
      use Ecto.Migration

      def import_from_csv(
            table_name,
            callback,
            should_convert_empty_to_nil \\ true
          ) do
        # Task.start(
        #   __MODULE__,
        #   :run,
        #   table_name: table_name,
        #   callback: callback,
        #   should_convert_empty_to_nil: should_convert_empty_to_nil
        # )
        run(
          {:table_name, table_name},
          {:callback, callback},
          {:should_convert_empty_to_nil, should_convert_empty_to_nil}
        )
      end

      def run(
            {:table_name, table_name},
            {:callback, callback},
            {:should_convert_empty_to_nil, should_convert_empty_to_nil}
          ) do
        %{module_name: module_name, csv_path: csv_path} = make_params(table_name)

        csv_path
        |> Path.absname()
        |> File.stream!()
        # headers: true option provides us a list of maps instead of list of lists
        |> CSV.decode!(headers: true)
        |> Enum.reduce([], fn row, acc ->
          row
          |> map_escap_sql(should_convert_empty_to_nil)
          |> callback.(module_name, table_name)
          |> case do
            {:ok, data} -> [data | acc]
            _ -> acc
          end
        end)
      end

      def make_params(table_name) do
        base_path = Application.get_env(:core, :repo)[:seed_base_path]

        case table_name do
          "countries" ->
            csv_path =
              "20190826064752_seed_countries.csv"
              |> Path.expand(base_path)

            %{module_name: Countries, csv_path: csv_path}

          "services" ->
            csv_path =
              "20190902095958_seed_services.csv"
              |> Path.expand(base_path)

            %{module_name: Service, csv_path: csv_path}

          "service_groups" ->
            csv_path =
              "20190902000114_seed_service_groups.csv"
              |> Path.expand(base_path)

            %{module_name: ServiceGroup, csv_path: csv_path}

          "country_services" ->
            csv_path =
              "20190902103722_seed_country_services.csv"
              |> Path.expand(base_path)

            %{module_name: CountryService, csv_path: csv_path}

          "service_settings" ->
            csv_path =
              "20190902000115_seed_service_settings.csv"
              |> Path.expand(base_path)

            %{module_name: ServiceSetting, csv_path: csv_path}

          "dynamic_groups" ->
            csv_path =
              "20190921223408_seed_dynamic_groups.csv"
              |> Path.expand(base_path)

            %{module_name: DynamicGroup, csv_path: csv_path}

          "dynamic_screens" ->
            csv_path =
              "20190921223409_seed_dynamic_screens.csv"
              |> Path.expand(base_path)

            %{module_name: DynamicScreen, csv_path: csv_path}

          "dynamic_fields" ->
            csv_path =
              "20190921223406_seed_dynamic_fields.csv"
              |> Path.expand(base_path)

            %{module_name: DynamicField, csv_path: csv_path}

          "bridge_screens_groups" ->
            csv_path =
              "20190921223411_seed_dynamic_bridge_screens_groups.csv"
              |> Path.expand(base_path)

            %{module_name: DynamicBridgeScreensGroup, csv_path: csv_path}
        end
      end

      def map_escap_sql(map, should_convert_empty_to_nil) do
        for {key, value} <- map, into: %{} do
          case value do
            "null" ->
              {key, value}

            "" ->
              if should_convert_empty_to_nil do
                {key, nil}
              else
                {key, value}
              end

            _ ->
              {key, value}
          end
        end
      end

      def map_to_table(
            %{"id" => id} = params,
            module_name,
            table_name
          ) do
        # try do

        %{keys: keys, values: values} = make_keys_and_values(params)

        case Context.get_by(module_name, id: id) do
          nil ->
            Ecto.Adapters.SQL.query(
              Core.Repo,
              "INSERT INTO #{table_name} (\"#{keys}\") values (#{values})"
            )

          data ->
            Ecto.Adapters.SQL.query(
              Core.Repo,
              "UPDATE #{table_name} SET #{make_query_string(params)} WHERE ID=#{data.id}"
            )

            # params = convert_json_to_map(module_name, params)
            # Context.update(module_name, data, params)
        end
      end

      # defp convert_json_to_map(Countries, params) do
      #   Map.merge(
      #     params,
      #     %{
      #       "contact_info" => CoreWeb.Utils.CommonFunctions.string_to_map(params["contact_info"]),
      #       "unit_system" => CoreWeb.Utils.CommonFunctions.string_to_map(params["unit_system"])
      #     }
      #   )
      # end

      defp convert_json_to_map(_, params), do: params

      def make_keys_and_values(map) do
        map =
          for {key, value} <- map, into: %{} do
            case value do
              nil ->
                {key, "null"}

              _ ->
                value =
                  value
                  |> String.replace("'", "''")

                {key, ~s('#{value}')}
            end
          end

        keys =
          map
          |> Map.keys()
          |> Enum.join(~s(", "))

        values =
          map
          |> Map.values()
          |> Enum.join(", ")

        %{keys: keys, values: values}
      end

      def make_query_string(map) do
        map_len = map |> Map.keys() |> length

        {_, query_string} =
          map
          |> Enum.reduce({0, ""}, fn {k, v}, {count, str} ->
            count = count + 1

            if count == map_len do
              {count, str <> "#{k}=#{~s('#{v}')}"}
            else
              {count, str <> "#{k}=#{~s('#{v}')}, "}
            end
          end)

        query_string
      end
    end
  end
end
