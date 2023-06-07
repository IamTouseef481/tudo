defmodule CoreWeb.Utils.CommonFunctions do
  @moduledoc false
  import CoreWeb.Utils.Errors

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

  def string_to_map(obj \\ "{}")
  def string_to_map(nil), do: nil
  def string_to_map(obj) when is_list(obj), do: Enum.map(obj, &string_to_map(&1))

  def string_to_map(obj) do
    Regex.replace(~r/([{,])(\s*)([A-Za-z0-9_\-\']+):/, obj, "\\1\"\\3\":")
    |> String.replace("\"'", "\"")
    |> String.replace("'\"", "\"")
    |> Poison.decode!()
    |> keys_to_atoms
  end

  def keys_to_atoms(string_key_map) when is_map(string_key_map) do
    for {key, val} <- string_key_map, into: %{} do
      if is_struct(val) do
        if val.__struct__ in [DateTime, NaiveDateTime, Date, Time] do
          {String.to_atom(key), val}
        else
          {String.to_atom(key), keys_to_atoms(val)}
        end
      else
        {String.to_atom(key), keys_to_atoms(val)}
      end
    end
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

  def outer_camel_keys_to_snake(obj) do
    Enum.reduce(Map.keys(obj), %{}, fn key, acc ->
      snake =
        if is_atom(key), do: Recase.to_snake(Atom.to_string(key)), else: Recase.to_snake(key)

      val = Map.get(obj, key)
      Map.merge(acc, %{"#{snake}" => val})
    end)
  end

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

  def encode_location(nil), do: nil

  def decode_location(location) do
    if false == is_nil(location) do
      %Geo.Point{coordinates: {long, lat}} = Geo.WKB.decode!(location)
      %{lat: lat, long: long}
    else
      %{lat: nil, long: nil}
    end
  end

  def location_struct(%{lat: lat, long: long}) do
    %Geo.Point{
      coordinates: {long, lat},
      srid: 4326
    }
  end

  def add_geo(%{location: %{coordinates: {long, lat}}} = data) do
    %{data | geo: %{lat: lat, long: long}}
  end

  def add_geo(%{"location" => %{"coordinates" => {long, lat}}} = data) do
    %{data | "geo" => %{"lat" => lat, "long" => long}}
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

  def location(%{location: %{coordinates: {long, lat}}} = data) do
    %{data | location: %{lat: lat, long: long}}
  end

  def location(data) do
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

  def calculate_distance_between_two_coordinates(location1, location2),
    do: Distance.GreatCircle.distance(location1, location2) / 1000

  def calculate_distance_between_two_coordinates(coordinates_list)
      when is_list(coordinates_list),
      do: Distance.GreatCircle.distance(coordinates_list) / 1000

  def round_off_value(value, precision \\ 2) do
    if is_float(value), do: Float.round(value, precision), else: value
  end

  def compare_two_floats_with_buffer(backend_calculation, frontend_calculation) do
    #    0.011 is buffer for decimal conversions and round off
    if backend_calculation - frontend_calculation <= 0.011 and
         backend_calculation - frontend_calculation >= -0.011,
       do: true,
       else: false
  end

  def replace_strings(template, map) do
    Regex.replace(~r/{([a-z]+)?}/, template, fn _, match ->
      map[match]
    end)
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

  def get_role_list(list) do
    Enum.flat_map(list, fn %{"role" => role} ->
      [role]
    end)
  end

  def decode(data) do
    Poison.decode!(data)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Data not decoded"], __ENV__.line)
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
        ["unable to update business!"]
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  def convert_files(files) do
    Enum.map(files, fn file ->
      CoreWeb.Controllers.ImageController.get_files(file)
    end)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in fetching files"], __ENV__.line)
  end

  def check_user_role(user_roles) do
    cond do
      "bsp" in user_roles -> "bsp"
      "emp" in user_roles -> "emp"
      true -> "cmr"
    end
  end

  def owner_or_manager_validity(%{user_id: user_id, branch_id: branch_id}) do
    if Core.Employees.get_owner_or_manager_by_user_and_branch(user_id, branch_id) != nil do
      true
    else
      false
    end
  end

  def owner_or_manager_validity(%{user_id: user_id}) do
    if Core.Employees.get_owner_or_manager_by_user(user_id) != nil do
      true
    else
      false
    end
  end

  def make_full_name_from_profile(profile) do
    case profile do
      %{"first_name" => first_name, "last_name" => last_name} -> first_name <> " " <> last_name
      %{first_name: first_name, last_name: last_name} -> first_name <> " " <> last_name
      %{"first_name" => first_name} -> first_name
      %{first_name: first_name} -> first_name
      %{"last_name" => last_name} -> last_name
      %{last_name: last_name} -> last_name
      _ -> " "
    end
  end

  def to_hh_mm_ss(0), do: "0:00"

  def to_hh_mm_ss(seconds) do
    units = [3600, 60, 1]

    [h | t] =
      Enum.map_reduce(units, seconds, fn unit, val -> {div(val, unit), rem(val, unit)} end)
      |> elem(0)
      |> Enum.drop_while(&match?(0, &1))

    {h, t} = if length(t) == 0, do: {0, [h]}, else: {h, t}

    "#{h}:#{t |> Enum.map_join(":", fn x -> x |> Integer.to_string() |> String.pad_leading(2, "0") end)}"
  end

  def convert_float_to_next_integer(number, divisor) do
    float_number = number / divisor
    int_number = div(number, divisor)

    if float_number == int_number do
      int_number
    else
      int_number + 1
    end
  end

  def generate_url(
        event,
        id,
        title \\ "",
        description \\ "",
        image \\ "https://tudo.app/assets/images/logo.png"
      ) do
    link = "https://tudo.app?event=#{event}&id=#{id}"
    #    API needs string in argument analyticsInfo in itunesConnectAnalytics in at
    id = if is_binary(id), do: id, else: to_string(id)
    headers = []
    options = [ssl: [{:versions, [:"tlsv1.2", :"tlsv1.1", :tlsv1]}], recv_timeout: 45_000]
    api_key = System.get_env("FIREBASE_DYNAMIC_LINKS_API_KEY")

    dynamic_link = %{
      "dynamicLinkInfo" => %{
        "domainUriPrefix" => "https://tudo.app/link",
        "link" => link,
        "analyticsInfo" => %{
          "googlePlayAnalytics" => %{"utmCampaign" => event, "utmMedium" => "", "utmSource" => id},
          "itunesConnectAnalytics" => %{"at" => id, "ct" => event, "mt" => "", "pt" => ""}
        },
        #        "androidInfo" => %{
        #          "androidFallbackLink" => "",
        #          "androidLink" => "",
        #          # "androidMinPackageVersionCode" => "4.1",
        #          "androidPackageName" => "com.icreon.travelconnect"
        #        },
        #        "iosInfo" => %{
        #          "iosAppStoreId" => "1019546379",
        #          "iosBundleId" => "Tudo",
        #          "iosCustomScheme" => "",
        #          "iosFallbackLink" => "",
        #          "iosIpadBundleId" => "",
        #          "iosIpadFallbackLink" => ""
        #        },
        "navigationInfo" => %{
          "enableForcedRedirect" => true
        },
        "socialMetaTagInfo" => %{
          "socialTitle" => title,
          "socialDescription" => description,
          "socialImageLink" => image
        }
      },
      "suffix" => %{
        "option" => "SHORT"
      }
    }

    body = Poison.encode!(dynamic_link)
    HTTPoison.start()

    case HTTPoison.post(
           "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=#{api_key}",
           body,
           headers,
           options
         ) do
      {:ok, response} ->
        body = Poison.decode!(response.body)
        Map.get(body, "shortLink")

      {:error, cause} ->
        logger(__MODULE__, cause, :info, __ENV__.line)
    end
  end
end
