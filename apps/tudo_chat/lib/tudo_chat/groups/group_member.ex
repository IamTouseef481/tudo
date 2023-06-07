defmodule TudoChat.Groups.GroupMember do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias TudoChat.Groups.{Group, GroupMemberRole}

  schema "group_members" do
    field :user_id, :integer
    #    belongs_to :user, User
    belongs_to :group, Group
    belongs_to :role, GroupMemberRole, type: :string
    field :is_active, :boolean, default: true
    field :deleted_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(group_member, attrs) do
    group_member
    |> cast(attrs, [:group_id, :user_id, :is_active, :role_id, :deleted_at])
    |> validate_required([:group_id, :user_id, :role_id])
  end
end
