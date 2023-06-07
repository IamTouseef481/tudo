defmodule TudoChatWeb.Channels.TotalUnreadMessagesChannel do
  @moduledoc false
  use TudoChatWeb, :channel

  def join("total_unread_messages:user_id:" <> user_id, payload, socket) do
    if authorized?(payload) do
      logger(__MODULE__, user_id, :info, __ENV__.line)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (job:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
