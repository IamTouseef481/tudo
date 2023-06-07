defmodule TudoChatWeb.Helpers.FriendCircleHelper do
  @moduledoc false
  use TudoChatWeb, :chat_helper
  alias TudoChat.{FriendCircles, Groups}

  def update_friend_circle(params) do
    new()
    |> run(:get_friend_circle, &get_friend_circle/2, &abort/3)
    |> run(:group_member, &get_group_member/2, &abort/3)
    |> run(:friend_circle, &update_friend_circle/2, &abort/3)
    |> run(:updated_group_member, &update_group_member/2, &abort/3)
    |> transaction(TudoChat.Repo, params)
  end

  # -----------------------------------------------
  defp get_friend_circle(_, %{id: id}) do
    case FriendCircles.get_friend_circle(id) do
      nil -> {:error, ["friend request doesn't exist!"]}
      %{} = circle -> {:ok, circle}
      _ -> {:error, ["something went wrong"]}
    end
  end

  defp update_friend_circle(%{get_friend_circle: fc}, params) do
    case FriendCircles.update_friend_circle(fc, params) do
      {:ok, circle} -> {:ok, circle}
      {:error, error} -> {:error, error}
      _ -> {:error, ["something went wrong"]}
    end
  end

  defp get_group_member(%{get_friend_circle: %{group_id: group_id, user_to_id: user_id}}, _params) do
    case Groups.get_group_member_by(%{group_id: group_id, user_id: user_id}) do
      [] -> {:error, ["group member doesn't exist"]}
      [member] -> {:ok, member}
      [member | _] -> {:ok, member}
    end
  end

  defp update_group_member(
         %{get_friend_circle: _fc, group_member: member},
         %{status_id: "accept"} = _params
       ) do
    case Groups.update_group_member(member, %{is_active: true}) do
      {:ok, member} -> {:ok, member}
      {:error, error} -> {:error, error}
      _ -> {:error, ["something went wrong"]}
    end
  end

  defp update_group_member(
         %{get_friend_circle: _fc, group_member: member},
         %{status_id: "reject"} = _params
       ) do
    case Groups.delete_group_member(member) do
      {:ok, member} -> {:ok, member}
      {:error, error} -> {:error, error}
      _ -> {:error, ["something went wrong"]}
    end
  end

  defp update_group_member(%{get_friend_circle: _fc, group_member: member}, _params) do
    {:ok, member}
  end
end
