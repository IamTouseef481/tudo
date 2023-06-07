defmodule TudoChat.GroupMemberBlocks do
  @moduledoc """
  The GroupMemberBlocks context.
  """

  import Ecto.Query, warn: false
  alias TudoChat.Repo

  alias TudoChat.GroupMemberBlocks.GroupMemberBlock

  @doc """
  Returns the list of group_member_blocks.

  ## Examples

      iex> list_group_member_blocks()
      [%GroupMemberBlock{}, ...]

  """
  def list_group_member_blocks do
    Repo.all(GroupMemberBlock)
  end

  @doc """
  Gets a single group_member_block.

  Raises `Ecto.NoResultsError` if the Group member block does not exist.

  ## Examples

      iex> get_group_member_block!(123)
      %GroupMemberBlock{}

      iex> get_group_member_block!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group_member_block!(id), do: Repo.get!(GroupMemberBlock, id)

  def get_group_member_block_by(user_from, user_to, group_id) do
    from(b in GroupMemberBlock,
      where:
        b.user_from_id == ^user_from and
          b.user_to_id == ^user_to and
          b.group_id == ^group_id
    )
    |> Repo.all()
  end

  def get_group_member_block_by(user_from, group_id) do
    from(b in GroupMemberBlock,
      where: b.user_from_id == ^user_from and b.group_id == ^group_id
    )
    |> Repo.all()
  end

  def get_blocked_group_members(%{user_id: user_id, group_id: group_id}) do
    from(b in GroupMemberBlock,
      where: b.user_from_id == ^user_id and b.group_id == ^group_id
    )
    |> Repo.all()
  end

  @doc """
  Creates a group_member_block.

  ## Examples

      iex> create_group_member_block(%{field: value})
      {:ok, %GroupMemberBlock{}}

      iex> create_group_member_block(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group_member_block(attrs \\ %{}) do
    %GroupMemberBlock{}
    |> GroupMemberBlock.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group_member_block.

  ## Examples

      iex> update_group_member_block(group_member_block, %{field: new_value})
      {:ok, %GroupMemberBlock{}}

      iex> update_group_member_block(group_member_block, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group_member_block(%GroupMemberBlock{} = group_member_block, attrs) do
    group_member_block
    |> GroupMemberBlock.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group_member_block.

  ## Examples

      iex> delete_group_member_block(group_member_block)
      {:ok, %GroupMemberBlock{}}

      iex> delete_group_member_block(group_member_block)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group_member_block(%GroupMemberBlock{} = group_member_block) do
    Repo.delete(group_member_block)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group_member_block changes.

  ## Examples

      iex> change_group_member_block(group_member_block)
      %Ecto.Changeset{source: %GroupMemberBlock{}}

  """
  def change_group_member_block(%GroupMemberBlock{} = group_member_block) do
    GroupMemberBlock.changeset(group_member_block, %{})
  end
end
