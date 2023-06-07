defmodule TudoChatWeb.GraphQL.Resolvers.GroupMemberBlockResolver do
  @moduledoc false
  alias TudoChat.{GroupMemberBlocks, Groups}
  alias TudoChatWeb.Controllers.GroupMemberBlockController

  def group_member_blocks(_, _, _) do
    {:ok, GroupMemberBlocks.list_group_member_blocks()}
  end

  def blocking_group_member(_, %{input: %{group_id: group_id, user_to_id: user_to} = input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_from_id: current_user.id})

    with %{} <- Core.Accounts.get_user!(current_user.id),
         %{} <- Core.Accounts.get_user!(user_to),
         %{} <- TudoChat.Groups.get_group(group_id),
         {:ok, _} <- verify_group_member(group_id, user_to),
         {:ok, _} <- verify_group_member(group_id, current_user.id) do
      case input do
        %{block: true} -> block_group_member(input)
        %{block: false} -> unblock_group_member(input)
        _ -> {:error, ["block key missing in params!"]}
      end
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["any wrong id in params!"]}
    end
  end

  def block_group_member(input) do
    case GroupMemberBlockController.block_group_member(input) do
      {:ok, member} -> {:ok, member}
      {:error, error} -> {:error, error}
    end
  end

  def unblock_group_member(input) do
    case GroupMemberBlockController.unblock_group_member(input) do
      {:ok, member} -> {:ok, member}
      {:error, error} -> {:error, error}
    end
  end

  def block_get_by(_, %{input: %{group_id: group_id}}, %{context: %{current_user: current_user}}) do
    {:ok, GroupMemberBlocks.get_group_member_block_by(current_user.id, group_id)}
  end

  def verify_group_member(group_id, user_id) do
    case Groups.get_group_member_by(%{user_id: user_id, group_id: group_id}) do
      [] -> {:error, ["#{user_id} not a member of this group"]}
      _ -> {:ok, ["valid member"]}
    end
  end
end
