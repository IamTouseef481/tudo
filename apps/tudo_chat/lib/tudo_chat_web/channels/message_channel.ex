defmodule TudoChatWeb.Channels.MessageChannel do
  @moduledoc false
  use TudoChatWeb, :channel
  alias TudoChatWeb.Channels.Presence
  alias TudoChatWeb.Controllers.MessageController

  def join("message_created:group_id:" <> group_id, _payload, socket) do
    user_id = socket.assigns[:user_id] |> String.to_integer()
    payload = %{group_id: String.to_integer(group_id), user_id: user_id}

    case authorized?(payload) do
      true ->
        MessageController.mark_all_group_messages_read_for_this_user(
          user_id,
          String.to_integer(group_id)
        )

        Presence.track(socket, payload.user_id, %{})
        {:ok, socket}

      _ ->
        {:error, %{reason: "you're not member of this group"}}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        %{reason: "something wrong in joining message channel"},
        __ENV__.line
      )
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

  def handle_in("phx_close", _payload, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  def handle_in(_event, _payload, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  def terminate(_reason, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(%{user_id: user_id, group_id: group_id} = _payload) do
    case TudoChat.Groups.get_active_group_member_by(%{user_id: user_id, group_id: group_id}) do
      [] -> false
      _user -> true
    end
  end
end
