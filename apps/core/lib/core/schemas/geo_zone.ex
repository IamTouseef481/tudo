defmodule Core.Schemas.GeoZone do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{Cities, Countries, States}

  schema "geo_zones" do
    field :coordinates, Geo.PostGIS.Geometry
    field :description, :string
    field :slug, :string
    field :title, :string
    field :status_id, :string
    belongs_to :city, Cities
    belongs_to :state, States
    belongs_to :country, Countries
  end

  @doc false
  def changeset(geo_zone, attrs) do
    geo_zone
    |> cast(attrs, [:city_id, :state_id, :country_id, :title, :slug, :description, :coordinates])
    |> validate_required([:title, :slug, :coordinates])
  end
end
