defmodule Core.Schemas.Session do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :tenant, :string
    field :token, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:token, :tenant])
    |> validate_required([:token, :tenant])
  end
end
