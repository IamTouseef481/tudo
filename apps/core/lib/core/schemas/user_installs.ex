defmodule Core.Schemas.UserInstalls do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "user_installs" do
    field :device_info, :map
    field :device_token, :string
    field :fcm_token, :string
    field :os, :string
    belongs_to :user, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(user_installs, attrs) do
    user_installs
    |> cast(attrs, [:user_id, :fcm_token, :device_token, :os, :device_info])
    |> validate_required([:user_id, :device_token])
  end

  def changeset_for_update_fcm_token(user_installs, attrs) do
    user_installs
    |> cast(attrs, [:fcm_token])
  end
end
