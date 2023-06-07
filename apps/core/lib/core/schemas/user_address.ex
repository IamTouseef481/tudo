defmodule Core.Schemas.UserAddress do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "user_addresses" do
    field :address, :string
    field :primary, :boolean
    field :geo_location, Geo.PostGIS.Geometry
    field :geo, :map, virtual: true
    field :slug, :string
    field :zone_name, :string
    belongs_to :user, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(user_address, attrs) do
    user_address
    |> cast(attrs, [:user_id, :slug, :address, :geo_location, :geo, :primary, :zone_name])
    |> validate_required([:user_id, :address, :primary])
    |> put_location()
  end

  def put_location(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{geo: %{lat: lat, long: long}}} ->
        put_change(changeset, :geo_location, %Geo.Point{coordinates: {long, lat}, srid: 4326})

      _ ->
        changeset
    end
  end
end
