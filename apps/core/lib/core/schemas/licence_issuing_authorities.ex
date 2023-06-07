defmodule Core.Schemas.LicenceIssuingAuthorities do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.Countries

  schema "licence_issuing_authorities" do
    field :is_active, :boolean, default: false
    field :name, :string
    belongs_to :country, Countries

    timestamps()
  end

  @doc false
  def changeset(licence_issuing_authorities, attrs) do
    licence_issuing_authorities
    |> cast(attrs, [:country_id, :name, :is_active])
    |> validate_required([:name, :is_active])
  end
end
