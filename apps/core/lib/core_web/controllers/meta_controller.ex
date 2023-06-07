defmodule CoreWeb.Controllers.MetaController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.MetaData
  alias Core.Schemas.MetaBSP

  def index(conn, _params) do
    meta = MetaData.list_meta_bsp()
    render(conn, "index.html", meta: meta)
  end

  def new(conn, _params) do
    changeset = MetaData.change_meta_bsp(%MetaBSP{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"meta" => meta_params}) do
    case MetaData.create_meta_bsp(meta_params) do
      {:ok, _meta} ->
        conn
        |> put_flash(:info, "Meta created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    meta = MetaData.get_meta_bsp!(id)
    render(conn, "show.html", meta: meta)
  end

  def edit(conn, %{"id" => id}) do
    meta = MetaData.get_meta_bsp!(id)
    changeset = MetaData.change_meta_bsp(meta)
    render(conn, "edit.html", meta: meta, changeset: changeset)
  end

  def update(conn, %{"id" => id, "meta" => meta_params}) do
    meta = MetaData.get_meta_bsp!(id)

    case MetaData.update_meta_bsp(meta, meta_params) do
      {:ok, _meta} ->
        conn
        |> put_flash(:info, "Meta updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", meta: meta, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    meta = MetaData.get_meta_bsp!(id)
    {:ok, _meta} = MetaData.delete_meta_bsp(meta)

    conn
    |> put_flash(:info, "Meta deleted successfully.")
  end
end
