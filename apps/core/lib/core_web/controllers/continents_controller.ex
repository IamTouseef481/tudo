defmodule CoreWeb.Controllers.ContinentsController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.Regions
  alias Core.Schemas.Continents

  def index(conn, _params) do
    continents = Regions.list_continents()
    render(conn, "index.html", continents: continents)
  end

  def new(conn, _params) do
    changeset = Regions.change_continents(%Continents{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"continents" => continents_params}) do
    case Regions.create_continents(continents_params) do
      {:ok, _continents} ->
        conn
        |> put_flash(:info, "Continents created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    continents = Regions.get_continents!(id)
    render(conn, "show.html", continents: continents)
  end

  def edit(conn, %{"id" => id}) do
    continents = Regions.get_continents!(id)
    changeset = Regions.change_continents(continents)
    render(conn, "edit.html", continents: continents, changeset: changeset)
  end

  def update(conn, %{"id" => id, "continents" => continents_params}) do
    continents = Regions.get_continents!(id)

    case Regions.update_continents(continents, continents_params) do
      {:ok, _continents} ->
        conn
        |> put_flash(:info, "Continents updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", continents: continents, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    continents = Regions.get_continents!(id)
    {:ok, _continents} = Regions.delete_continents(continents)

    conn
    |> put_flash(:info, "Continents deleted successfully.")
  end
end
