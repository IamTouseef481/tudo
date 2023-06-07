defmodule Core.Schemas.RawBusiness do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{BusinessType, UserStatuses}

  schema "raw_businesses" do
    field :name, :string
    field :owner_name, :string
    field :role, :string
    field :email, :string
    field :alternate_email, :string
    field :website, :string
    field :description, :string
    field :phone, :string
    field :alternate_phone1, :string
    field :alternate_phone2, :string
    field :raw_phone_details, :string
    field :address, :map
    field :business_profile_info, :string
    field :terms_and_conditions_url, :string
    field :social_fb, :string
    field :social_google, :string
    field :social_yelp, :string
    field :social_instagram, :string
    field :licence_no, :string
    field :licence_photos, {:array, :map}
    field :licence_expiry_date, :utc_datetime
    field :custom_license_issuing_authority, :string
    field :personal_identification, :map
    field :profile_pictures, {:array, :map}
    field :employees_count, :integer, default: 0
    field :settings, :map
    field :est_year, :utc_datetime
    field :street_address, :string
    field :city, :string
    field :zip_code, :string
    field :primary_naics_description, :string
    field :zone_ids, {:array, :integer}
    field :location, Geo.PostGIS.Geometry
    field :is_active, :boolean, default: true
    field :is_head_office, :boolean, default: false
    field :is_claimed, :boolean, default: false
    field :auto_assign, :boolean, default: true
    field :rating, :float, default: 0.0
    field :rating_count, :integer, default: 0
    field :geo, :map, virtual: true
    field :general_liability_insured, :boolean, default: false
    field :surety_bonded, :boolean, default: false
    field :other_details, :string
    field :social_profile, :map
    field :search_tsvector, Core.CustomTypes.TsVectorType
    belongs_to :business_type, BusinessType
    belongs_to :status, UserStatuses, type: :string

    timestamps()
  end

  @all_fields ~w|name owner_name role email alternate_email website description phone alternate_phone1 alternate_phone2
    raw_phone_details address business_profile_info terms_and_conditions_url social_fb social_google social_yelp
    social_instagram licence_no licence_photos licence_expiry_date custom_license_issuing_authority
    personal_identification profile_pictures employees_count settings est_year street_address city zip_code
    primary_naics_description zone_ids location is_active is_head_office auto_assign rating rating_count
    geo general_liability_insured surety_bonded other_details social_profile status_id is_claimed search_tsvector|a

  @doc false
  def changeset(branch, attrs) do
    branch
    |> cast(attrs, @all_fields)
    # |> put_location()
    |> trim(attrs)
  end

  # def put_location(changeset) do
  #   case changeset do
  #     %Ecto.Changeset{valid?: true, changes: %{geo: %{lat: lat, long: long}}} ->
  #       put_change(changeset, :location, %Geo.Point{coordinates: {long, lat}, srid: 4326})

  #     _ ->
  #       changeset
  #   end
  # end

  def trim(changeset, %{"business_profile_info" => business_profile_info, "name" => name}) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        changeset
        |> put_change(:business_profile_info, String.trim(business_profile_info))
        |> put_change(:name, String.trim(name))

      _ ->
        changeset
    end
  end

  def trim(changeset, _), do: changeset
end
