defmodule CoreWeb.Controllers.LicenceIssuingAuthoritiesController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.Legals
  alias Core.Schemas.LicenceIssuingAuthorities

  def index(conn, _params) do
    licence_issuing_authorities = Legals.list_licence_issuing_authorities()
    render(conn, "index.html", licence_issuing_authorities: licence_issuing_authorities)
  end

  def new(conn, _params) do
    changeset = Legals.change_licence_issuing_authorities(%LicenceIssuingAuthorities{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"licence_issuing_authorities" => licence_issuing_authorities_params}) do
    case Legals.create_licence_issuing_authorities(licence_issuing_authorities_params) do
      {:ok, _licence_issuing_authorities} ->
        conn
        |> put_flash(:info, "Licence issuing authorities created successfully.")
        |> redirect(to: "/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    licence_issuing_authorities = Legals.get_licence_issuing_authorities!(id)
    render(conn, "show.html", licence_issuing_authorities: licence_issuing_authorities)
  end

  def edit(conn, %{"id" => id}) do
    licence_issuing_authorities = Legals.get_licence_issuing_authorities!(id)
    changeset = Legals.change_licence_issuing_authorities(licence_issuing_authorities)

    render(conn, "edit.html",
      licence_issuing_authorities: licence_issuing_authorities,
      changeset: changeset
    )
  end

  def update(conn, %{
        "id" => id,
        "licence_issuing_authorities" => licence_issuing_authorities_params
      }) do
    licence_issuing_authorities = Legals.get_licence_issuing_authorities!(id)

    case Legals.update_licence_issuing_authorities(
           licence_issuing_authorities,
           licence_issuing_authorities_params
         ) do
      {:ok, _licence_issuing_authorities} ->
        conn
        |> put_flash(:info, "Licence issuing authorities updated successfully.")
        |> redirect(to: "/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          licence_issuing_authorities: licence_issuing_authorities,
          changeset: changeset
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    licence_issuing_authorities = Legals.get_licence_issuing_authorities!(id)

    {:ok, _licence_issuing_authorities} =
      Legals.delete_licence_issuing_authorities(licence_issuing_authorities)

    conn
    |> put_flash(:info, "Licence issuing authorities deleted successfully.")
  end
end
