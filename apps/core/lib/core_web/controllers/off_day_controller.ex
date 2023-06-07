defmodule CoreWeb.Controllers.OffDayController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.OffDays
  alias Core.Schemas.Holiday

  def create_holidays(input) do
    if Time.compare(input.from, input.to) != :eq do
      case OffDays.get_holiday_by_branch(input) do
        [] ->
          OffDays.create_holiday(input)

        holidays ->
          valid =
            Enum.reduce(holidays, [], fn holiday, acc ->
              if Timex.between?(holiday.from, input.from, input.to,
                   inclusive: :start,
                   inclusive: :end
                 ) or
                   Timex.between?(input.from, holiday.from, holiday.to,
                     inclusive: :start,
                     inclusive: :end
                   ) or
                   Timex.between?(input.to, holiday.from, holiday.to,
                     inclusive: :start,
                     inclusive: :end
                   ) do
                [holiday | acc]
              else
                acc
              end
            end)

          case valid do
            [] -> OffDays.create_holiday(input)
            _ -> {:error, ["Holiday already exists in your Holiday caleneda"]}
          end
      end
    else
      {:error, ["From and To: time is same, correct your entry and try again."]}
    end
  end

  def update_holidays(%{id: id} = input) do
    case OffDays.get_holiday(id: id) do
      nil -> {:error, ["Holiday doesn't exist in your Holiday calendar"]}
      data -> OffDays.update_holiday(data, input)
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_holidays(%{id: id}) do
    case OffDays.get_holiday(id: id) do
      nil -> {:error, ["Holiday doesn't exist in your Holiday calendar"]}
      data -> OffDays.delete_holiday(data)
    end
  rescue
    _all -> {:error, ["Something went wrong, can't delete"]}
  end

  def index(conn, _params) do
    holidays = OffDays.list_holidays()
    render(conn, "index.html", holidays: holidays)
  end

  def new(conn, _params) do
    changeset = OffDays.change_holiday(%Holiday{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"holiday" => holiday_params}) do
    case OffDays.create_holiday(holiday_params) do
      {:ok, _holiday} ->
        conn
        |> put_flash(:info, "Holiday created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    holiday = OffDays.get_holiday!(id)
    render(conn, "show.html", holiday: holiday)
  end

  def edit(conn, %{"id" => id}) do
    holiday = OffDays.get_holiday!(id)
    changeset = OffDays.change_holiday(holiday)
    render(conn, "edit.html", holiday: holiday, changeset: changeset)
  end

  def update(conn, %{"id" => id, "holiday" => holiday_params}) do
    holiday = OffDays.get_holiday!(id)

    case OffDays.update_holiday(holiday, holiday_params) do
      {:ok, _holiday} ->
        conn
        |> put_flash(:info, "Holiday updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", holiday: holiday, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    holiday = OffDays.get_holiday!(id)
    {:ok, _holiday} = OffDays.delete_holiday(holiday)

    conn
    |> put_flash(:info, "Holiday deleted successfully.")
  end
end
