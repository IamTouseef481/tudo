defmodule TudoChatWeb.Channels.UnreadGroupMessagesChannel do
  @moduledoc false
  use TudoChatWeb, :channel
  import TudoChatWeb.Utils.CommonFunctions

  def join("unread_group_messages:group_id:" <> group_id, payload, socket) do
    payload = Map.merge(keys_to_atoms(payload), %{group_id: group_id})

    logger(__MODULE__, group_id, :info, __ENV__.line)

    case Map.has_key?(payload, :user_id) do
      true ->
        case authorized?(payload) do
          true ->
            {:ok, socket}

          _ ->
            {:error, %{reason: "you're not a member of this group"}}
        end

      _ ->
        {:error, %{reason: "user_id missing in payload params"}}
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
  defp authorized?(%{user_id: user_id, group_id: group_id} = _payload) do
    case TudoChat.Groups.get_group_member_by(%{user_id: user_id, group_id: group_id}) do
      [] -> false
      _user -> true
    end
  end
end
