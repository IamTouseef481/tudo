defmodule TudoChatWeb.Utils.CommonFunctions do
  @moduledoc false
  import TudoChatWeb.Utils.Errors

  def number(min \\ 100_000, max \\ 999_999) do
    # :rand.uniform(count)
    Enum.random(min..max)
  end

  def string(length \\ 24) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  def sort_list(list, key) do
    Enum.sort_by(list, & &1[key])
  end

  def string_to_map(obj \\ "{}") do
    Regex.replace(~r/([{,])(\s*)([A-Za-z0-9_\-\']+):/, obj, "\\1\"\\3\":")
    |> String.replace("\"'", "\"")
    |> String.replace("'\"", "\"")
    |> Poison.decode!()
    |> keys_to_atoms
  end

  def keys_to_atoms(string_key_map) when is_map(string_key_map) do
    for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), keys_to_atoms(val)}
  end

  def keys_to_atoms(string_key_list) when is_list(string_key_list) do
    string_key_list
    |> Enum.map(&keys_to_atoms/1)
  end

  def keys_to_atoms(value), do: value

  def snake_keys_to_camel(objects) when is_list(objects) do
    Enum.map(objects, &snake_keys_to_camel(&1))
  end

  def snake_keys_to_camel(object) when is_map(object) do
    Enum.reduce(Map.keys(object), %{}, fn key, acc ->
      camel =
        if is_atom(key), do: Recase.to_camel(Atom.to_string(key)), else: Recase.to_camel(key)

      val = Map.get(object, key)

      cond do
        is_struct(val) ->
          if val.__struct__ in [DateTime, NaiveDateTime, Date, Time] do
            Map.merge(acc, %{"#{camel}" => val})
          else
            Map.merge(acc, %{"#{camel}" => snake_keys_to_camel(val)})
          end

        key in [:__meta__] ->
          acc

        is_map(val) or is_list(val) ->
          Map.merge(acc, %{"#{camel}" => snake_keys_to_camel(val)})

        true ->
          Map.merge(acc, %{"#{camel}" => val})
      end
    end)
  end

  def snake_keys_to_camel(non_object_data), do: non_object_data

  def camel_keys_to_snake(objects) when is_list(objects) do
    Enum.map(objects, &camel_keys_to_snake(&1))
  end

  def camel_keys_to_snake(object) when is_map(object) do
    Enum.reduce(Map.keys(object), %{}, fn key, acc ->
      snake =
        if is_atom(key), do: Recase.to_snake(Atom.to_string(key)), else: Recase.to_snake(key)

      val = Map.get(object, key)

      cond do
        is_struct(val) ->
          if val.__struct__ in [DateTime, NaiveDateTime, Date, Time] do
            Map.merge(acc, %{"#{snake}" => val})
          else
            Map.merge(acc, %{"#{snake}" => camel_keys_to_snake(val)})
          end

        key in [:__meta__] ->
          acc

        is_map(val) or is_list(val) ->
          Map.merge(acc, %{"#{snake}" => camel_keys_to_snake(val)})

        true ->
          Map.merge(acc, %{"#{snake}" => val})
      end
    end)
  end

  def camel_keys_to_snake(non_object_data), do: non_object_data

  def string_to_datetime(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, datetime, _} ->
        datetime

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        datetime
    end
  end

  def encode_location(%{lat: lat, long: long}) do
    location = %Geo.Point{
      coordinates: {long, lat},
      srid: 4326
    }

    Geo.WKB.encode!(location)
  end

  def add_geo(%{location: %{coordinates: {long, lat}}} = data) do
    %{data | geo: %{lat: lat, long: long}}
  end

  def add_geo(%{geo_location: %{coordinates: {long, lat}}} = data) do
    %{data | geo: %{lat: lat, long: long}}
  end

  #  used in fetching geo zones
  def add_geo(%{coordinates: %{coordinates: coordinates}} = zone) when is_list(coordinates) do
    updated_coordinates =
      Enum.map(zone.coordinates.coordinates, fn inner_coordinates ->
        Enum.map(inner_coordinates, fn inner_coordinate ->
          {long, lat} = inner_coordinate
          %{lat: lat, long: long}
        end)
      end)

    zone = Map.delete(zone, :coordinates)
    Map.merge(zone, %{geo: updated_coordinates})
  end

  def add_geo(data) do
    data
  end

  def location_dest(%{location_dest: %{coordinates: {long, lat}}} = data) do
    %{data | location_dest: %{lat: lat, long: long}}
  end

  def location_dest(data) do
    data
  end

  def location_src(%{location_src: %{coordinates: {long, lat}}} = data) do
    %{data | location_src: %{lat: lat, long: long}}
  end

  def location_src(data) do
    data
  end

  def branch_location(%{branch_location: %{coordinates: {long, lat}}} = data) do
    %{data | branch_location: %{lat: lat, long: long}}
  end

  def branch_location(data) do
    data
  end

  def calculate_distance_between_two_coordinates(location1, location2) do
    distance_in_meters = Distance.GreatCircle.distance(location1, location2)
    distance_in_kilometers = distance_in_meters / 1000
    distance_in_kilometers
  end

  def calculate_distance_between_two_coordinates(coordinates_list)
      when is_list(coordinates_list) do
    distance_in_meters = Distance.GreatCircle.distance(coordinates_list)
    distance_in_kilometers = distance_in_meters / 1000
    distance_in_kilometers
  end

  def map_deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  # Key exists in both maps, and both values are maps as well.
  # These can be merged recursively.
  defp deep_resolve(_key, %{} = left, %{} = right) do
    map_deep_merge(left, right)
  end

  # Key exists in both maps, but at least one of the values is
  # NOT a map. We fall back to standard merge behavior, preferring
  # the value on the right.
  defp deep_resolve(_key, _left, right) do
    right
  end

  def replace_strings(template, map) do
    Regex.replace(~r/{([a-z]+)?}/, template, fn _, match ->
      map[match]
    end)
  end

  def get_role_list(list) do
    Enum.flat_map(list, fn %{"role" => role} ->
      [role]
    end)
  end

  def decode_rescue_error(error) do
    cond do
      Map.has_key?(error, :message) and Map.has_key?(error, :constraint) ->
        e = String.split(error.message, "\n")
        error = error.constraint <> ", " <> hd(e)
        ["#{error}"]

      Map.has_key?(error, :message) ->
        e = String.split(error.message, "\n")
        error = hd(e)
        ["#{error}"]

      true ->
        ["unable to update!"]
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unexpected error occurred"], __ENV__.line)
  end

  def convert_files(files) do
    Enum.map(files, fn file ->
      TudoChatWeb.Controllers.FileController.get_files(file)
    end)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch files"], __ENV__.line)
  end

  def to_hh_mm_ss(0), do: "0:00"

  def convert_seconds_to_time_string(time_in_seconds) do
    seconds = rem(time_in_seconds, 60)
    min_hours = trunc((time_in_seconds - seconds) / 60)
    minutes = rem(min_hours, 60)
    hours = trunc((min_hours - minutes) / 60)
    Enum.map_join([hours, minutes, seconds], ":", &if(&1 < 10, do: "0#{&1}", else: to_string(&1)))
  end

  def convert_string_time_to_time_format(time_in_seconds) do
    {:ok, time} =
      convert_seconds_to_time_string(time_in_seconds)
      |> Time.from_iso8601()

    time
  end
end
