defmodule TudoChatWeb.Controllers.ComGroupMessageController do
  @moduledoc false
  use TudoChatWeb, :controller
  alias TudoChat.Messages
  alias TudoChat.Messages.ComGroupMessage

  def index(conn, _params) do
    com_group_messages = Messages.list_com_group_messages()
    render(conn, "index.html", com_group_messages: com_group_messages)
  end

  def new(conn, _params) do
    changeset = Messages.change_com_group_message(%ComGroupMessage{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"com_group_message" => com_group_message_params}) do
    case Messages.create_com_group_message(com_group_message_params) do
      {:ok, _com_group_message} ->
        conn
        |> put_flash(:info, "Com group message created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    com_group_message = Messages.get_com_group_message!(id)
    render(conn, "show.html", com_group_message: com_group_message)
  end

  @spec edit(Plug.Conn.t(), map) :: Plug.Conn.t()
  def edit(conn, %{"id" => id}) do
    com_group_message = Messages.get_com_group_message!(id)
    changeset = Messages.change_com_group_message(com_group_message)
    render(conn, "edit.html", com_group_message: com_group_message, changeset: changeset)
  end

  def update(conn, %{"id" => id, "com_group_message" => com_group_message_params}) do
    com_group_message = Messages.get_com_group_message!(id)

    case Messages.update_com_group_message(com_group_message, com_group_message_params) do
      {:ok, _com_group_message} ->
        conn
        |> put_flash(:info, "Com group message updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", com_group_message: com_group_message, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    com_group_message = Messages.get_com_group_message!(id)
    {:ok, _com_group_message} = Messages.delete_com_group_message(com_group_message)

    conn
    |> put_flash(:info, "Com group message deleted successfully.")
  end
end
