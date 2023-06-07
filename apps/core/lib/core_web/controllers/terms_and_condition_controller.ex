defmodule CoreWeb.Controllers.TermsAndConditionController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.Business
  alias Core.Schemas.TermsAndCondition

  def index(conn, _params) do
    terms_and_conditions = Business.list_terms_and_conditions()
    render(conn, "index.html", terms_and_conditions: terms_and_conditions)
  end

  def new(conn, _params) do
    changeset = Business.change_terms_and_condition(%TermsAndCondition{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"terms_and_condition" => terms_and_condition_params}) do
    case Business.create_terms_and_condition(terms_and_condition_params) do
      {:ok, _terms_and_condition} ->
        conn
        |> put_flash(:info, "Terms and condition created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    terms_and_condition = Business.get_terms_and_condition!(id)
    render(conn, "show.html", terms_and_condition: terms_and_condition)
  end

  def edit(conn, %{"id" => id}) do
    terms_and_condition = Business.get_terms_and_condition!(id)
    changeset = Business.change_terms_and_condition(terms_and_condition)
    render(conn, "edit.html", terms_and_condition: terms_and_condition, changeset: changeset)
  end

  def update(conn, %{"id" => id, "terms_and_condition" => terms_and_condition_params}) do
    terms_and_condition = Business.get_terms_and_condition!(id)

    case Business.update_terms_and_condition(terms_and_condition, terms_and_condition_params) do
      {:ok, _terms_and_condition} ->
        conn
        |> put_flash(:info, "Terms and condition updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", terms_and_condition: terms_and_condition, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    terms_and_condition = Business.get_terms_and_condition!(id)
    {:ok, _terms_and_condition} = Business.delete_terms_and_condition(terms_and_condition)

    conn
    |> put_flash(:info, "Terms and condition deleted successfully.")
  end
end
