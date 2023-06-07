defmodule Core.Repo.Migrations.AddRawBusinesses do
  @moduledoc false
  use Ecto.Migration

  @table :raw_businesses
  def change do
    drop_if_exists table(@table)

    create table(@table) do
      add :name, :string
      add :owner_name, :string
      add :role, :string
      add :email, :string
      add :alternate_email, :string
      add :raw_phone_details, :string
      add :website, :string
      add :description, :text
      add :phone, :string
      add :alternate_phone1, :string
      add :alternate_phone2, :string
      add :address, :map
      add :business_profile_info, :text
      add :terms_and_conditions_url, :string
      add :social_fb, :string
      add :social_google, :string
      add :social_yelp, :string
      add :social_instagram, :string
      add :licence_no, :string
      add :licence_photos, {:array, :map}
      add :licence_expiry_date, :utc_datetime
      add :custom_license_issuing_authority, :string
      add :personal_identification, :map
      add :profile_pictures, {:array, :map}
      add :employees_count, :integer, default: 0
      add :settings, :map
      add :social_profile, :map
      add :est_year, :utc_datetime
      add :street_address, :string
      add :city, :string
      add :zip_code, :string
      add :primary_naics_description, :string
      add :zone_ids, {:array, :integer}
      add :location, :geometry
      add :is_head_office, :boolean, default: false, null: false
      add :auto_assign, :boolean, default: true, null: false
      add :is_active, :boolean, default: true, null: false
      add :rating, :float, default: 0.0
      add :rating_count, :integer, default: 0
      add :general_liability_insured, :boolean, default: true, null: false
      add :surety_bonded, :boolean, default: true, null: false
      add :other_details, :text
      add :is_claimed, :boolean, default: false
      add :status_id, references(:user_statuses, type: :varchar, on_delete: :nothing)
      add :business_type_id, references(:business_types, on_delete: :nothing)

      timestamps()
    end
  end
end
