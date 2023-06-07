defmodule Core.Schemas.Branch do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import CoreWeb.Utils.Errors

  schema "branches" do
    field :name, :string
    field :description, :string
    field :phone, :string
    field :licence_no, :string
    field :licence_photos, {:array, :map}
    field :licence_expiry_date, :utc_datetime
    field :custom_license_issuing_authority, :string
    field :personal_identification, :map
    field :profile_pictures, {:array, :map}
    field :employees_count, :integer, default: 0
    field :settings, :map
    field :est_year, :utc_datetime
    field :address, :map
    field :zone_ids, {:array, :integer}
    field :location, Geo.PostGIS.Geometry
    field :is_active, :boolean, default: true
    field :is_head_office, :boolean, default: false
    field :auto_assign, :boolean, default: true
    field :rating, :float, default: 0.0
    field :rating_count, :integer, default: 0
    field :geo, :map, virtual: true
    field :general_liability_insured, :boolean, default: false
    field :surety_bonded, :boolean, default: false
    field :other_details, :string
    field :outdoor_sticker_pdf, :string
    field :social_profile, :map
    field :search_tsvector, Core.CustomTypes.TsVectorType
    #    field :business_id, :id
    belongs_to :business, Core.Schemas.Business
    belongs_to :status, Core.Schemas.UserStatuses, type: :string
    #    field :licence_issuing_authority_id, :id
    belongs_to :licence_issuing_authority, Core.Schemas.LicenceIssuingAuthorities
    #    field :city_id, :id
    belongs_to :city, Core.Schemas.Cities
    #    field :country_id, :integer
    belongs_to :country, Core.Schemas.Countries
    belongs_to :business_type, Core.Schemas.BusinessType
    has_many :employees, Core.Schemas.Employee
    has_many :branch_services, Core.Schemas.BranchService

    timestamps()
  end

  @required_fields ~w|


      name
      phone
      est_year
      address
      geo
      zone_ids
      business_id
      business_type_id
  |a

  @all_fields ~w|
      name
      description
      profile_pictures
      employees_count
      settings
      phone
      licence_no
      licence_photos
      licence_expiry_date
      personal_identification
      est_year
      address
      zone_ids
      location
      is_active
      is_head_office
      auto_assign
      rating
      rating_count
      geo
      general_liability_insured
      surety_bonded
      other_details
      business_id
      custom_license_issuing_authority
      licence_issuing_authority_id
      city_id
      country_id
      status_id
      business_type_id
      search_tsvector
      social_profile
      outdoor_sticker_pdf
  |a

  @doc false
  def changeset(branch, attrs) do
    branch
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    |> put_location()
  end

  def update_changeset(branch, attrs) do
    branch
    |> cast(attrs, @all_fields)
    |> put_location()
  end

  def put_location(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{geo: %{long: long, lat: lat}}} ->
        logger(__MODULE__, %Geo.Point{coordinates: {long, lat}, srid: 4326}, :info, __ENV__.line)
        put_change(changeset, :location, %Geo.Point{coordinates: {long, lat}, srid: 4326})

      _ ->
        changeset
    end
  end
end
