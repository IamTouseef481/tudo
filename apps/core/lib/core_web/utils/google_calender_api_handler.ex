defmodule CoreWeb.Utils.GoogleCalenderApiHandler do
  @moduledoc """
  This module is to handle Google Api Requests
  """

  alias CoreWeb.Utils.HttpRequest
  alias CoreWeb.Utils.DateTimeFunctions

  def create_event_on_google_calender(
        %{
          arrive_at: arrive_at,
          expected_work_duration: ewd,
          location: location,
          job_title: job_title,
          job_description: job_description,
          access_token: access_token,
          time_zone: time_zone,
          calender_id: calender_id
        } = params
      ) do
    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer " <> access_token}
    ]

    url =
      "https://www.googleapis.com/calendar/v3/calendars/#{calender_id}/events?sendNotifications=true&sendUpdates=all"

    end_date_time =
      DateTimeFunctions.time_to_datetime(ewd, arrive_at)
      |> DateTimeFunctions.convert_utc_datatime_to_string()

    arrive_at = DateTimeFunctions.convert_utc_datatime_to_string(arrive_at)

    data =
      %{
        "end" => %{"dateTime" => end_date_time, "timeZone" => time_zone},
        "start" => %{"dateTime" => arrive_at, "timeZone" => time_zone},
        "location" => location,
        "description" => job_description,
        "summary" => job_title
        # "attendees" => [
        #   %{
        #     "displayName" => first_name <> " " <> last_name,
        #     "email" => email,
        #     "comment" => "bsp"
        #   }
        # ]
      }
      |> is_source_exist(params)

    case HttpRequest.post(url, data, headers, hackney: []) do
      {:ok, data} -> {:ok, data}
      {:error, message} -> {:ok, message}
    end
  end

  def create_event_on_google_calender(_), do: {:ok, "Something Went Wrong"}

  def update_event_on_google_calender(
        %{
          "arrive_at" => arrive_at,
          "expected_work_duration" => ewd,
          "refresh_token" => refresh_token,
          "event_id" => event_id
        },
        params
      ) do
    case get_access_token_and_token_id(refresh_token) do
      {:ok, %{"access_token" => access_token, "id_token" => id_token}} ->
        {:ok, %{email: calender_id}} = Core.Google.user_info(id_token)

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token}
        ]

        url = "https://www.googleapis.com/calendar/v3/calendars/#{calender_id}/events/#{event_id}"

        end_date_time =
          DateTimeFunctions.time_to_datetime(ewd, arrive_at)
          |> DateTimeFunctions.convert_utc_datatime_to_string()

        arrive_at = DateTimeFunctions.convert_utc_datatime_to_string(arrive_at)

        data =
          Map.merge(
            %{
              "end" => %{"dateTime" => end_date_time},
              "start" => %{"dateTime" => arrive_at}
            },
            params
          )

        case HttpRequest.patch(url, data, headers, hackney: []) do
          {:ok, _data} -> {:ok, "google calender updated"}
          {:error, _data} -> {:ok, "Error in updating Google Calender"}
        end

      {:error, message} ->
        {:error, message}
    end
  end

  def list_of_events(%{refresh_token: refresh_token}) do
    case get_access_token_and_token_id(refresh_token) do
      {:ok, %{"access_token" => access_token, "id_token" => id_token}} ->
        {:ok, %{email: calender_id}} = Core.Google.user_info(id_token)

        headers = [
          {"Accept", "application/json"},
          {"Authorization", "Bearer " <> access_token}
        ]

        url =
          "https://www.googleapis.com/calendar/v3/calendars/#{calender_id}/events?orderBy=updated"

        case HttpRequest.get(url, headers, hackney: []) do
          {:ok, data} ->
            {:ok, data}

          {:error, message} ->
            {:error, message}
        end
    end
  end

  def get_access_token_and_token_id(refresh_token) do
    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    url = "https://developers.google.com/oauthplayground/refreshAccessToken"

    case HttpRequest.post(url, %{refresh_token: refresh_token}, headers, hackney: []) do
      {:ok, data} ->
        {:ok,
         data["Response"]["message-body"]
         |> Base.decode64!()
         |> Poison.decode!()}

      {:error, message} ->
        {:error, message}
    end
  end

  def delete_event_on_google_calender(%{
        "refresh_token" => refresh_token,
        "event_id" => event_id
      }) do
    case get_access_token_and_token_id(refresh_token) do
      {:ok, %{"access_token" => access_token, "id_token" => id_token}} ->
        {:ok, %{email: calender_id}} = Core.Google.user_info(id_token)

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token}
        ]

        url = "https://www.googleapis.com/calendar/v3/calendars/#{calender_id}/events/#{event_id}"

        case HttpRequest.delete(url, headers, hackney: []) do
          {:ok, _data} -> {:ok, "google event deleted"}
          {:error, _data} -> {:ok, "Error in deleted Google Calender Event"}
        end

      {:error, message} ->
        {:error, message}
    end
  end

  def is_source_exist(data, params) do
    if Map.has_key?(params, :source) do
      Map.put(data, "source", params.source)
    else
      data
    end
  end
end
