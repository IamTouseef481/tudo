defmodule Core.Schemas.PushNotification do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "push_notifications" do
    field :acl_role_id, :string
    field :description, :string
    field :pushed_at, :utc_datetime
    field :read, :boolean, default: false
    field :title, :string
    belongs_to :user, Core.Schemas.User
    belongs_to :branch, Core.Schemas.Branch

    timestamps()
  end

  @doc false
  def changeset(push_notification, attrs) do
    push_notification
    |> cast(attrs, [:title, :description, :read, :pushed_at, :acl_role_id, :user_id, :branch_id])
    |> validate_required([:description, :pushed_at, :acl_role_id, :user_id])
  end
end
