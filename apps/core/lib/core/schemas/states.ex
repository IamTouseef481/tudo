defmodule Core.Schemas.States do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "states" do
    field :capital, :string
    field :fips_code, :string
    field :name, :string
    field :short_code, :string
    #    field :country_id, :id
    belongs_to :country, Core.Schemas.Countries

    timestamps()
  end

  @doc false
  def changeset(states, attrs) do
    states
    |> cast(attrs, [:country_id, :name, :short_code, :capital, :fips_code])
    |> validate_required([:country_id, :name, :short_code, :capital, :fips_code])
    |> unique_constraint(:short_code)
  end
end
