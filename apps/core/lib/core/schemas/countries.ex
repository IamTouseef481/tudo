defmodule Core.Schemas.Countries do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "countries" do
    field :capital, :string
    field :code, :string
    field :currency_code, :string
    field :currency_symbol, :string
    field :isd_code, :string
    field :name, :string
    field :nmc_code, :string
    field :official_name, :string
    field :is_active, :boolean
    field :contact_info, :map
    field :unit_system, :map
    # field :language_id, :id
    #    belongs_to(:language, Tudo.I18n.Language) #by mistake or for any purpose
    belongs_to(:language, Core.Schemas.Languages)
    # field :continent_id, :id
    #    belongs_to(:continent, Tudo.Regions.Continent) #by mistake or for any purpose
    belongs_to(:continent, Core.Schemas.Continents)

    timestamps()
  end

  @doc false
  def changeset(countries, attrs) do
    countries
    |> cast(attrs, [
      :continent_id,
      :language_id,
      :name,
      :contact_info,
      :official_name,
      :capital,
      :code,
      :nmc_code,
      :isd_code,
      :currency_code,
      :currency_symbol,
      :unit_system,
      :is_active
    ])
    |> validate_required([
      :continent_id,
      :language_id,
      :name,
      :official_name,
      :capital,
      :code,
      :nmc_code,
      :isd_code,
      :currency_code,
      :currency_symbol
    ])
  end
end
