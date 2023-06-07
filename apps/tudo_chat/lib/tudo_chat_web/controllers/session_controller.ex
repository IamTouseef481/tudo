defmodule TudoChatWeb.Controllers.SessionController do
  @moduledoc false
  use TudoChatWeb, :controller
  alias TudoChat.Accounts
  alias TudoChat.Accounts.Session

  def index(conn, _params) do
    sessions = Accounts.list_sessions()
    render(conn, "index.html", sessions: sessions)
  end

  def new(conn, _params) do
    changeset = Accounts.change_session(%Session{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"session" => session_params}) do
    case Accounts.create_session(session_params) do
      {:ok, _session} ->
        conn
        |> put_flash(:info, "Session created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    session = Accounts.get_session!(id)
    render(conn, "show.html", session: session)
  end

  def edit(conn, %{"id" => id}) do
    session = Accounts.get_session!(id)
    changeset = Accounts.change_session(session)
    render(conn, "edit.html", session: session, changeset: changeset)
  end

  def update(conn, %{"id" => id, "session" => session_params}) do
    session = Accounts.get_session!(id)

    case Accounts.update_session(session, session_params) do
      {:ok, _session} ->
        conn
        |> put_flash(:info, "Session updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", session: session, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    session = Accounts.get_session!(id)
    {:ok, _session} = Accounts.delete_session(session)

    conn
    |> put_flash(:info, "Session deleted successfully.")
  end
end
