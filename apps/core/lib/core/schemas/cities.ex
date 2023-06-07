defmodule Core.Schemas.Cities do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cities" do
    field :details, :map
    field :name, :string
    field :search_vector, :string
    field :short_code, :string
    field :zip, :string
    #    field :state_id, :id
    belongs_to :state, Core.Schemas.States
    timestamps()
  end

  @doc false
  def changeset(cities, attrs) do
    cities
    |> cast(attrs, [:state_id, :name, :short_code, :details, :zip, :search_vector])
    |> validate_required([:state_id, :name, :short_code, :details, :zip, :search_vector])
  end
end
