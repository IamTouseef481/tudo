defmodule CoreWeb.Controllers.AclRoleController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.Acl
  alias Core.Acl.AclRole

  def index(conn, _params) do
    acl_roles = Acl.list_acl_roles()
    render(conn, "index.html", acl_roles: acl_roles)
  end

  def new(conn, _params) do
    changeset = Acl.change_acl_role(%AclRole{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"acl_role" => acl_role_params}) do
    case Acl.create_acl_role(acl_role_params) do
      {:ok, _acl_role} ->
        conn
        |> put_flash(:info, "Acl role created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    acl_role = Acl.get_acl_role!(id)
    render(conn, "show.html", acl_role: acl_role)
  end

  def edit(conn, %{"id" => id}) do
    acl_role = Acl.get_acl_role!(id)
    changeset = Acl.change_acl_role(acl_role)
    render(conn, "edit.html", acl_role: acl_role, changeset: changeset)
  end

  def update(conn, %{"id" => id, "acl_role" => acl_role_params}) do
    acl_role = Acl.get_acl_role!(id)

    case Acl.update_acl_role(acl_role, acl_role_params) do
      {:ok, _acl_role} ->
        conn
        |> put_flash(:info, "Acl role updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", acl_role: acl_role, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    acl_role = Acl.get_acl_role!(id)
    {:ok, _acl_role} = Acl.delete_acl_role(acl_role)

    conn
    |> put_flash(:info, "Acl role deleted successfully.")
  end
end
