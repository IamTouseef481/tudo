defmodule TudoChat.Calls.Call do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias TudoChat.Groups.Group

  schema "calls" do
    field :initiator_id, :integer
    belongs_to :group, Group

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [
      :initiator_id,
      :group_id
    ])
    |> validate_required([:initiator_id, :group_id])
  end
end
