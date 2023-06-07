defmodule CoreWeb.Utils.GoogleApiHandler do
  @moduledoc """
  This module is to handle Google Api Requests
  """

  alias CoreWeb.Utils.HttpRequest

  def distance_api(coordinates) do
    key = System.get_env("GOOGLE_API_KEY")
    url_params = create_url_params(coordinates, key)
    url = "https://maps.googleapis.com/maps/api/distancematrix/json?#{url_params}"

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"apiKey", key}
    ]

    case HttpRequest.get(url, headers, []) do
      {:ok, rows} -> {:ok, rows}
      {:error, error} -> {:error, error}
    end
  end

  defp create_url_params(%{src_lat: src_lat, src_long: src_long} = coordinates, key) do
    "units=imperial&origins=#{coordinates.origin_lat},#{coordinates.origin_long}|#{src_lat},#{src_long}&destinations=#{src_lat},#{src_long}|#{coordinates.dest_lat},#{coordinates.dest_long}&key=#{key}"
  end

  defp create_url_params(coordinates, key) do
    "units=imperial&origins=#{coordinates.origin_lat},#{coordinates.origin_long}&destinations=#{coordinates.dest_lat},#{coordinates.dest_long}&key=#{key}"
  end
end
