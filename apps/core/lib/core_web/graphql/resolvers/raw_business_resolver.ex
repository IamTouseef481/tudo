defmodule CoreWeb.GraphQL.Resolvers.RawBusinessResolver do
  @moduledoc false
  alias Core.RawBusiness

  require Logger

  def create_raw_businesses(_, %{input: input}, %{context: %{current_user: current_user}}) do
    if "web" in current_user.acl_role_id do
      start = input[:start_file_number] || 1
      end_ = input[:end_file_number] || 40
      Task.start(__MODULE__, :run, start_file_number: start, end_file_number: end_)

      {:ok, %{message: "Raw Business Insertion Started..."}}
    else
      {:error, %{message: "You Don't Have Permission"}}
    end
  end

  def run({:start_file_number, start}, {:end_file_number, end_}) do
    Enum.reduce(start..end_, start, fn _, acc ->
      stream_large_data_from_csv(acc)
      acc + 1
    end)
  end

  def stream_large_data_from_csv(file_number) do
    base_path = Application.get_env(:core, :repo)[:seed_raw_business]

    #    Logger.info("Reading File raw_businesses-#{file_number}")

    "raw_businesses-#{file_number}.csv"
    |> Path.expand(base_path)
    |> File.stream!()
    |> CSV.decode!(headers: headers())
    |> Stream.drop(1)
    |> then(fn data ->
      data |> process_cache()
      []
    end)
    |> Stream.run()

    #    Logger.info("Insertion Ended For File raw_businesses-#{file_number}")
  end

  def process_cache(chunked_data) do
    chunked_data
    |> Enum.chunk_every(1000)
    |> Enum.each(fn small_chunk ->
      Enum.each(small_chunk, &map_escap_sql(&1))
    end)
  end

  defp map_escap_sql(map) do
    params = for {key, value} <- map, into: %{}, do: {key, ~s(#{value})}
    params = params |> process_location()
    params = params |> process_address()
    params = Map.put(params, "status_id", "confirmation_pending")

    phone = params["phone"]
    name = params["name"]
    address = params["address"]

    case RawBusiness.get_by(phone, name, address) do
      nil ->
        case RawBusiness.create(params) do
          {:error, error} ->
            Logger.info("""
               #{inspect(error, pretty: true)}
            """)

          {:ok, %{id: id}} ->
            Logger.info("""
               CREATE #{inspect(id, pretty: true)}
            """)
        end

      %Core.Schemas.RawBusiness{} = data ->
        case RawBusiness.update(data, params) do
          {:error, error} ->
            Logger.info("""
              #{inspect(error, pretty: true)}
            """)

          {:ok, %{id: id}} ->
            Logger.info("""
              UPDATE #{inspect(id, pretty: true)}
            """)
        end

      _ ->
        Logger.info("""
          RECORDS SKIPPED!
        """)
    end
  rescue
    exception ->
      Logger.error("""
      #{inspect(map, pretty: true)}

      #{inspect(exception, pretty: true)}
      """)

      {:ok, opened_file} =
        File.open("apps/core/priv/repo/rescued_seeds/raw_businesses.csv", [:append])

      map
      |> Map.values()
      |> Enum.join(",")
      |> (&IO.binwrite(opened_file, ~s(\n#{&1}))).()

      File.close(opened_file)
  end

  defp process_location(params) do
    case params["location"] do
      "" ->
        Map.put(params, "location", %Geo.Point{})

      value ->
        [lat, long] = value |> String.split(",")

        lat =
          lat
          |> contains?("(")
          |> then(fn
            true -> lat |> String.replace("(", "")
            false -> lat
          end)

        long =
          long
          |> contains?(")")
          |> then(fn
            true -> long |> String.replace(")", "")
            false -> long
          end)

        location = %Geo.Point{
          coordinates: {long |> trim |> float, lat |> trim |> float},
          srid: 4326
        }

        Map.put(params, "location", location)
    end
  end

  defp process_address(params) do
    address = %{
      "city" => params["city"],
      "type" => "",
      "state" => params["sate"],
      "address" => params["address"],
      "country" => params["country"],
      "primary" => true,
      "zip_code" => params["zip_code"]
    }

    Map.put(params, "address", address)
  end

  defp float(value) do
    if contains?(value, "."), do: value |> String.to_float(), else: value |> String.to_integer()
  rescue
    exception ->
      Logger.error("""
      #{value}
      #{inspect(exception, pretty: true)}
      """)
  end

  defp contains?(value, find), do: String.contains?(value, find)

  defp trim(value), do: String.trim(value)

  defp headers do
    ~w|name owner_name role email alternate_email raw_phone_details phone alternate_phone1 alternate_phone2
    street city state zip_code country address location business_profile_info website terms_and_conditions_url
    social_fb social_google social_yelp social_instagram status_id|
  end
end
