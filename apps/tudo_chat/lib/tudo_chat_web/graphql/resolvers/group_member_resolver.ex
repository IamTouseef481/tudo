defmodule TudoChatWeb.GraphQL.Resolvers.GroupMemberResolver do
  @moduledoc false
  alias TudoChat.Groups
  alias TudoChatWeb.Controllers.GroupMemberController

  def group_members(_, _, _) do
    {:ok, Groups.list_group_members()}
  end

  def create_group_members(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_from_id: current_user.id})

    case GroupMemberController.create_group_members(input) do
      {:ok, members} -> {:ok, members}
      {:error, error} -> {:error, error}
    end
  end

  def update_group_member(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{current_user_id: current_user.id})

    case GroupMemberController.update_group_member(input) do
      {:ok, member} -> {:ok, member}
      {:error, error} -> {:error, error}
    end
  end

  def delete_group_member(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{current_user_id: current_user.id})

    case GroupMemberController.delete_group_member(input) do
      {:ok, member} -> {:ok, member}
      {:error, error} -> {:error, error}
    end
  end
end
