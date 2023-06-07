defmodule TudoChatWeb.Controllers.CalendarController do
  @moduledoc false
  use TudoChatWeb, :controller
  alias TudoChat.Calendars
  alias TudoChat.Calendars.Calendar

  def index(conn, _params) do
    calendars = Calendars.list_calendars()
    render(conn, "index.html", calendars: calendars)
  end

  def new(conn, _params) do
    changeset = Calendars.change_calendar(%Calendar{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"calendar" => calendar_params}) do
    case Calendars.create_calendar(calendar_params) do
      {:ok, _calendar} ->
        conn
        |> put_flash(:info, "Calendar created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    calendar = Calendars.get_calendar!(id)
    render(conn, "show.html", calendar: calendar)
  end

  def edit(conn, %{"id" => id}) do
    calendar = Calendars.get_calendar!(id)
    changeset = Calendars.change_calendar(calendar)
    render(conn, "edit.html", calendar: calendar, changeset: changeset)
  end

  def update(conn, %{"id" => id, "calendar" => calendar_params}) do
    calendar = Calendars.get_calendar!(id)

    case Calendars.update_calendar(calendar, calendar_params) do
      {:ok, _calendar} ->
        conn
        |> put_flash(:info, "Calendar updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", calendar: calendar, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    calendar = Calendars.get_calendar!(id)
    {:ok, _calendar} = Calendars.delete_calendar(calendar)

    conn
    |> put_flash(:info, "Calendar deleted successfully.")
  end
end
