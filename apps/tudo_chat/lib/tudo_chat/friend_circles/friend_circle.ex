defmodule TudoChat.FriendCircles.FriendCircle do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias TudoChat.FriendCircles.FriendCircleStatus
  alias TudoChat.Groups.Group

  schema "friend_circles" do
    field :request_message, :string
    field :user_from_id, :integer
    field :user_to_id, :integer
    belongs_to :status, FriendCircleStatus, type: :string
    belongs_to :group, Group

    timestamps()
  end

  @doc false
  def changeset(friend_circle, attrs) do
    friend_circle
    |> cast(attrs, [:request_message, :user_from_id, :user_to_id, :status_id, :group_id])
    |> validate_required([:user_from_id, :user_to_id, :status_id])
  end
end
