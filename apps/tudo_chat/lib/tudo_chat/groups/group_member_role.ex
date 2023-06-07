defmodule TudoChat.Groups.GroupMemberRole do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "group_member_roles" do
    field :description, :string
    field :id, :string, primary_key: true
  end

  @doc false
  def changeset(group_member_role, attrs) do
    group_member_role
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
