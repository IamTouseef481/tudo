defmodule TudoChatWeb.Controllers.GroupMemberBlockController do
  @moduledoc false
  use TudoChatWeb, :controller
  alias TudoChat.GroupMemberBlocks

  def block_group_member(
        %{user_from_id: user_from, user_to_id: user_to, group_id: group_id} = input
      ) do
    case GroupMemberBlocks.get_group_member_block_by(user_from, user_to, group_id) do
      [] -> create_group_member_block(input)
      [_block] -> {:error, ["group member already blocked"]}
      _ -> {:error, ["error while getting group member block for blocking"]}
    end
  end

  defp create_group_member_block(input) do
    case GroupMemberBlocks.create_group_member_block(input) do
      {:ok, member_block} -> {:ok, member_block}
      {:error, error} -> {:error, error}
      _ -> {:error, ["error while creating group member block"]}
    end
  end

  def unblock_group_member(%{user_from_id: user_from, user_to_id: user_to, group_id: group_id}) do
    case GroupMemberBlocks.get_group_member_block_by(user_from, user_to, group_id) do
      [] -> {:error, ["group member already unblocked"]}
      [block] -> delete_group_member_block(block)
      _ -> {:error, ["error while getting group member block for unblocking"]}
    end
  end

  defp delete_group_member_block(block) do
    case GroupMemberBlocks.delete_group_member_block(block) do
      {:ok, member_block} -> {:ok, member_block}
      {:error, error} -> {:error, error}
      _ -> {:error, ["error while deleting group member block"]}
    end
  end
end
