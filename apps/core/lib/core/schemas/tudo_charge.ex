defmodule Core.Schemas.TudoCharge do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "tudo_charges" do
    field :slug, :string
    field :name, :string
    field :application_id, :string
    field :value, :float
    field :is_percentage, :boolean, default: true
    belongs_to :country, Core.Schemas.Countries
    belongs_to :branch, Core.Schemas.Branch

    timestamps()
  end

  @doc false
  def changeset(tudo_charge, attrs) do
    tudo_charge
    |> cast(attrs, [
      :name,
      :slug,
      :value,
      :is_percentage,
      :country_id,
      :application_id,
      :branch_id
    ])
    |> validate_required([:slug, :value])
  end
end
