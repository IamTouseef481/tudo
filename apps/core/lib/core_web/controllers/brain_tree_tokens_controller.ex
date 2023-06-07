defmodule CoreWeb.Controllers.BrainTreeTokensController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.Payments
  alias Core.Schemas.BrainTreeTokens

  def index(conn, _params) do
    brain_tree_tokens = Payments.list_brain_tree_tokens()
    render(conn, "index.html", brain_tree_tokens: brain_tree_tokens)
  end

  def new(conn, _params) do
    changeset = Payments.change_brain_tree_tokens(%BrainTreeTokens{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"brain_tree_tokens" => brain_tree_tokens_params}) do
    case Payments.create_brain_tree_tokens(brain_tree_tokens_params) do
      {:ok, _brain_tree_tokens} ->
        conn
        |> put_flash(:info, "Brain tree tokens created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    brain_tree_tokens = Payments.get_brain_tree_tokens!(id)
    render(conn, "show.html", brain_tree_tokens: brain_tree_tokens)
  end

  def edit(conn, %{"id" => id}) do
    brain_tree_tokens = Payments.get_brain_tree_tokens!(id)
    changeset = Payments.change_brain_tree_tokens(brain_tree_tokens)
    render(conn, "edit.html", brain_tree_tokens: brain_tree_tokens, changeset: changeset)
  end

  def update(conn, %{"id" => id, "brain_tree_tokens" => brain_tree_tokens_params}) do
    brain_tree_tokens = Payments.get_brain_tree_tokens!(id)

    case Payments.update_brain_tree_tokens(brain_tree_tokens, brain_tree_tokens_params) do
      {:ok, _brain_tree_tokens} ->
        conn
        |> put_flash(:info, "Brain tree tokens updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", brain_tree_tokens: brain_tree_tokens, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    brain_tree_tokens = Payments.get_brain_tree_tokens!(id)
    {:ok, _brain_tree_tokens} = Payments.delete_brain_tree_tokens(brain_tree_tokens)

    conn
    |> put_flash(:info, "Brain tree tokens deleted successfully.")
  end
end
