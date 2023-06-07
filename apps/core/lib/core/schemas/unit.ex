defmodule Core.Schemas.Unit do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "units" do
    field :description, :string
    field :name, :string
    field :slug, :string
    field :code, :string
    belongs_to :country, Core.Schemas.Countries

    timestamps()
  end

  @doc false
  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [:name, :slug, :description, :code, :country_id])
    |> validate_required([:slug, :country_id])
  end
end
