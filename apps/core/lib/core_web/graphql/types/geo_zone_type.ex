defmodule CoreWeb.GraphQL.Types.GeoZoneType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :geo_zone_type do
    field :id, :integer
    field :title, :string
    field :slug, :string
    field :description, :string
    field :status_id, :string
    field :city, :city_type, resolve: assoc(:city)
    field :state, :state_type, resolve: assoc(:state)
    field :country, :country_type, resolve: assoc(:country)
    field :geo, list_of(:json)
  end

  input_object :get_zone_input_type do
    field :country_id, non_null(:integer)
  end
end
