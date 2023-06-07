defmodule TudoChatWeb.Helpers.GroupHelper do
  @moduledoc false
  use TudoChatWeb, :chat_helper
  alias TudoChat.Groups

  #
  # Main actions
  #
  def create_group(params) do
    new()
    |> run(:group, &create_group/2, &abort/3)
    |> run(:group_member, &create_group_super_admin/2, &abort/3)
    |> transaction(TudoChat.Repo, params)
  end

  # -----------------------------------------------

  defp create_group(_, params) do
    params = Map.merge(params, %{created_at: DateTime.utc_now()})

    case Groups.create_group(params) do
      {:ok, group} ->
        {:ok, group}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["error in creating my net chat group"]}
    end
  end

  defp create_group_super_admin(%{group: %{id: group_id} = chat_group}, %{
         created_by_id: user_id,
         on_branch_active: true,
         current_user_id: current_user_id
       }) do
    params = [
      %{user_id: user_id, group_id: group_id, role_id: "super_admin"},
      %{user_id: current_user_id, group_id: group_id, role_id: "super_admin"}
    ]

    [head | _] =
      Enum.map(params, fn param ->
        case Groups.create_group_member(param) do
          {:ok, member} ->
            send_broadcast(member.user_id, chat_group)
            {:ok, member}

          {:error, error} ->
            {:error, error}

          _ ->
            {:error, ["error in making group super admin"]}
        end
      end)

    head
  end

  defp create_group_super_admin(%{group: %{id: group_id} = chat_group}, %{created_by_id: user_id}) do
    params = %{user_id: user_id, group_id: group_id, role_id: "super_admin"}

    case Groups.create_group_member(params) do
      {:ok, member} ->
        send_broadcast(member.user_id, chat_group)
        {:ok, member}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["error in making group super admin"]}
    end
  end

  def send_broadcast(user_id, chat_group) do
    TudoChatWeb.Endpoint.broadcast(
      "user:user_id:#{user_id}",
      "group_created",
      %{
        chat_group: TudoChatWeb.Channels.UserChannel.create_group_socket(chat_group)
      }
    )
  end
end
