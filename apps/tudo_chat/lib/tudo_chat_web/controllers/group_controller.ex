defmodule TudoChatWeb.Controllers.GroupController do
  @moduledoc false
  use TudoChatWeb, :controller
  alias TudoChat.Groups
  alias TudoChat.Groups.Group
  alias TudoChatWeb.Helpers.GroupHelper

  @default_error ["unexpected error occurred!"]

  def create_group(input) do
    with {:ok, _last, all} <- GroupHelper.create_group(input),
         %{group: group} <- all do
      {:ok, group}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def index(conn, _params) do
    groups = Groups.list_groups()
    render(conn, "index.html", groups: groups)
  end

  def new(conn, _params) do
    changeset = Groups.change_group(%Group{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"group" => group_params}) do
    case Groups.create_group(group_params) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Group created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    render(conn, "show.html", group: group)
  end

  def edit(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    changeset = Groups.change_group(group)
    render(conn, "edit.html", group: group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Groups.get_group!(id)

    case Groups.update_group(group, group_params) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    {:ok, _group} = Groups.delete_group(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
  end
end
