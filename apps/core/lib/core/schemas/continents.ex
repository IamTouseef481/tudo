defmodule Core.Schemas.Continents do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "continents" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(continents, attrs) do
    continents
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
  end
end
