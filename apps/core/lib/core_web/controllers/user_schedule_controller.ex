defmodule CoreWeb.Controllers.UserScheduleController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.Schedules
  alias Core.Schemas.UserSchedule

  def create_user_schedule(input) do
    if owner_or_manager_validity(input) do
      case Schedules.create_user_schedule(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def get_user_schedule(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Schedules.get_user_schedule(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = user_schedule -> {:ok, user_schedule}
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def update_user_schedule(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Schedules.get_user_schedule(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = user_schedule -> Schedules.update_user_schedule(user_schedule, input)
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_user_schedule(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Schedules.get_user_schedule(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = user_schedule -> Schedules.delete_user_schedule(user_schedule)
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def index(conn, _params) do
    user_schedules = Schedules.list_user_schedules()
    render(conn, "index.html", user_schedules: user_schedules)
  end

  def new(conn, _params) do
    changeset = Schedules.change_user_schedule(%UserSchedule{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_schedule" => user_schedule_params}) do
    case Schedules.create_user_schedule(user_schedule_params) do
      {:ok, _user_schedule} ->
        conn
        |> put_flash(:info, "User schedule created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_schedule = Schedules.get_user_schedule!(id)
    render(conn, "show.html", user_schedule: user_schedule)
  end

  def edit(conn, %{"id" => id}) do
    user_schedule = Schedules.get_user_schedule!(id)
    changeset = Schedules.change_user_schedule(user_schedule)
    render(conn, "edit.html", user_schedule: user_schedule, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user_schedule" => user_schedule_params}) do
    user_schedule = Schedules.get_user_schedule!(id)

    case Schedules.update_user_schedule(user_schedule, user_schedule_params) do
      {:ok, _user_schedule} ->
        conn
        |> put_flash(:info, "User schedule updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user_schedule: user_schedule, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_schedule = Schedules.get_user_schedule!(id)
    {:ok, _user_schedule} = Schedules.delete_user_schedule(user_schedule)

    conn
    |> put_flash(:info, "User schedule deleted successfully.")
  end
end
