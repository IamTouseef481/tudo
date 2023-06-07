defmodule CoreWeb.Workers.GoogleCalenderWorker do
  @moduledoc false
  alias Core.{Calendars, GoogleCalenders}
  alias CoreWeb.Utils.GoogleCalenderApiHandler

  def perform(refresh_token, user_id) do
    tudo_calender = Calendars.get_calendar_by_user_id(user_id)
    event_ids = user_id |> get_event_ids

    case GoogleCalenderApiHandler.list_of_events(%{refresh_token: refresh_token}) do
      {:ok, %{"items" => items}} -> update_tudo_calender(items, event_ids, tudo_calender)
      {:error, message} -> {:ok, message}
    end
  end

  def update_tudo_calender(items, event_ids, tudo_calender) do
    cond do
      event_ids == [] ->
        update_tudo_calender(items, tudo_calender)

      true ->
        Enum.reject(items, fn item -> item["id"] in event_ids end)

        Enum.flat_map(items, fn item ->
          if item["id"] in event_ids, do: make_short_object(item), else: []
        end)
        |> update_tudo_calender(tudo_calender)
    end
  end

  def update_tudo_calender(items, tudo_calender) when not is_nil(tudo_calender) do
    schedule = update_in(tudo_calender.schedule, ["events"], fn _x -> items end)

    case Calendars.update_calendar(tudo_calender, %{schedule: schedule}) do
      {:ok, _data} -> {:ok, "updated sucessfully"}
      {:error, _error} -> {:ok, "Error in udating"}
    end
  end

  def make_short_object(map) do
    %{
      "end" => map["end"],
      "start" => map["start"],
      "summary" => map["summary"],
      "description" => map["description"],
      "location" => map["location"],
      "id" => map["id"],
      "attendees" => map["attendees"]
    }
  end

  def get_event_ids(user_id) do
    GoogleCalenders.get_google_calender_by_user_id(user_id)
    |> Enum.reduce([], fn
      %{cmr_event: cmr_event}, acc ->
        if is_nil(cmr_event), do: [], else: [cmr_event] ++ acc

      %{bsp_event: bsp_event}, acc ->
        if is_nil(bsp_event), do: [], else: [bsp_event] ++ acc
    end)
  end
end
