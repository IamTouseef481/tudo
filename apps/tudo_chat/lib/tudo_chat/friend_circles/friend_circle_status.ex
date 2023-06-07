defmodule TudoChat.FriendCircles.FriendCircleStatus do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "friends_circle_statuses" do
    field :description, :string
    field :id, :string, primary_key: true
  end

  @doc false
  def changeset(friend_circle_status, attrs) do
    friend_circle_status
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
