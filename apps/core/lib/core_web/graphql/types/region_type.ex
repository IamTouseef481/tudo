defmodule CoreWeb.GraphQL.Types.RegionType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :language_type do
    field :id, :id
    field :code, :string
    field :is_active, :boolean
    field :name, :string
    #    field :country, list_of :country_type, resolve: assoc(:country)
  end

  object :continent_type do
    field :id, :id
    field :code, :string
    field :name, :string
    #    field :countries, list_of(:country), resolve: assoc(:countries)
  end

  object :country_type do
    field :id, :id
    field :capital, :string
    field :code, :string
    field :currency_code, :string
    field :currency_symbol, :string
    field :isd_code, :string
    field :name, :string
    field :nmc_code, :string
    field :official_name, :string
    field :is_active, :boolean
    field :contact_info, :json
    field :unit_system, :json
    field :language_id, :id
    field :language, :language_type, resolve: assoc(:language)
    field :continent, :continent_type, resolve: assoc(:continent)

    #    field :states, list_of(:state), resolve: assoc(:states)
  end

  object :state_type do
    field :id, :id
    field :capital, :string
    field :fips_code, :string
    field :name, :string
    field :short_code, :string
    field :country, :country_type, resolve: assoc(:country)

    #    field :cities, list_of(:city), resolve: assoc(:cities)
  end

  object :city_type do
    field :id, :id
    field :details, :json
    field :name, :string
    field :zip, :string
    field :short_code, :string

    field :state, :state_type, resolve: assoc(:state)
  end

  #
  #  object :unit_type do
  #    field :id, :id
  #    field :name, :string
  #    field :slug, :string
  #    field :description, :string
  #    field :code, :string
  #    field :country, :country_type, resolve: assoc(:country)
  #  end
  #
  #  input_object :unit_input_type do
  #    field :name, :string
  #    field :slug, non_null :string
  #    field :description, :string
  #    field :code, :string
  #    field :country_id, non_null :integer
  #  end
  #  input_object :unit_update_type do
  #    field :id, :id
  #    field :name, :string
  #    field :slug, :string
  #    field :description, :string
  #    field :code, :string
  #    field :country_id, :integer
  #  end
  #  input_object :unit_get_by_country_type do
  #    field :country_id, non_null :integer
  #  end
  #  input_object :unit_delete_type do
  #    field :id, non_null :integer
  #  end

  input_object :translation_input_type do
    field :language_code, non_null(:string)
  end
end
