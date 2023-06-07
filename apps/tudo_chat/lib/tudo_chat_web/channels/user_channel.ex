defmodule TudoChatWeb.Channels.UserChannel do
  @moduledoc false
  use TudoChatWeb, :channel
  import TudoChatWeb.Utils.CommonFunctions

  def join("user:user_id:" <> user_id, payload, socket) do
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

  def handle_in("phx_close", _payload, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  def terminate(_reason, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def create_message_socket(message) when is_map(message) do
    message_for_rest_socket =
      Map.drop(message, [
        :__meta__,
        :__struct__,
        :user_from,
        :user_to,
        :group,
        :message_meta,
        :job_status,
        :message_tags
      ])

    Map.merge(message_for_rest_socket, %{user_group_members: []})
    |> snake_keys_to_camel()
  end

  def create_message_socket(_message), do: nil

  def create_group_socket(group) do
    group = TudoChat.Repo.preload(group, group_members: :role)

    group =
      Map.drop(Map.from_struct(group), [
        :__meta__,
        :__struct__,
        :group_status,
        :group_type
      ])
      |> Map.merge(%{
        group_members: [],
        user_group_members: user_member_for_socket(group.group_members),
        unread_message_count: 0,
        last_message: nil
      })
      |> snake_keys_to_camel()

    user_group_members =
      Enum.map(group["userGroupMembers"], fn user_group_member ->
        Map.put(user_group_member, "profile", camel_keys_to_snake(user_group_member["profile"]))
      end)

    Map.merge(group, %{"userGroupMembers" => user_group_members, "id" => to_string(group["id"])})
  end

  @spec user_member_for_socket(maybe_improper_list) :: any
  def user_member_for_socket(user_group_members) when is_list(user_group_members) do
    Enum.reduce(user_group_members, [], fn
      %{user_id: user_id} = gm, acc ->
        [
          %{
            id: to_string(gm.id),
            role: %{description: gm.role.description, id: gm.role.id},
            is_active: gm.is_active,
            user_id: user_id,
            user: Core.Accounts.get_user_short_object(user_id)
          }
          | acc
        ]

      _, acc ->
        acc
    end)
  end
end
