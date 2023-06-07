defmodule Core.Schemas.CharitableOrganization do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "charitable_organizations" do
    field :address, :map
    field :employees_count, :integer
    field :est_year, :utc_datetime
    field :is_active, :boolean, default: false
    field :licence_expiry_date, :utc_datetime
    field :licence_no, :string
    field :licence_photos, {:array, :map}
    field :name, :string
    field :personal_identification, :map
    field :phone, :string
    field :profile_pictures, {:array, :map}
    field :rating, :float
    field :settings, :map
    field :zone_ids, {:array, :integer}
    field :location, Geo.PostGIS.Geometry
    belongs_to :licence_issuing_authority, Core.Schemas.LicenceIssuingAuthorities
    belongs_to :city, Core.Schemas.Cities

    timestamps()
  end

  @doc false
  def changeset(charitable_organizations, attrs) do
    charitable_organizations
    |> cast(attrs, [
      :name,
      :phone,
      :location,
      :licence_no,
      :licence_photos,
      :licence_expiry_date,
      :personal_identification,
      :profile_pictures,
      :employees_count,
      :settings,
      :est_year,
      :address,
      :zone_ids,
      :is_active,
      :rating,
      :licence_issuing_authority_id,
      :city_id
    ])
    |> validate_required([
      :name,
      :phone,
      :licence_no,
      :licence_photos,
      :licence_expiry_date,
      :personal_identification,
      :profile_pictures,
      :employees_count,
      :settings,
      :est_year,
      :address,
      :zone_ids,
      :is_active,
      :rating
    ])
  end
end
