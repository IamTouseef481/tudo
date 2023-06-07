defmodule TudoChat.GroupMemberBlocks.GroupMemberBlock do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_member_blocks" do
    field :user_from_id, :integer
    field :user_to_id, :integer
    belongs_to :group, TudoChat.Groups.Group

    timestamps()
  end

  @doc false
  def changeset(group_member_block, attrs) do
    group_member_block
    |> cast(attrs, [:user_from_id, :user_to_id, :group_id])
    |> validate_required([:user_from_id, :user_to_id, :group_id])
  end
end
