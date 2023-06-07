defmodule Core.Repo.Migrations.CreateTableBranches do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:branches) do
      add :name, :string
      add :description, :text
      add :phone, :string
      add :licence_no, :string
      add :licence_photos, {:array, :map}
      add :licence_expiry_date, :utc_datetime
      add :custom_license_issuing_authority, :string
      add :personal_identification, :map
      add :profile_pictures, {:array, :map}
      add :employees_count, :integer, default: 0
      add :settings, :map
      add :est_year, :utc_datetime
      add :address, :map
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

      add :status_id, references(:user_statuses, type: :varchar, on_delete: :nothing)

      add :licence_issuing_authority_id,
          references(:licence_issuing_authorities, on_delete: :nothing)

      add :business_id, references(:businesses, on_delete: :nothing)
      add :business_type_id, references(:business_types, on_delete: :nothing)
      add :city_id, references(:cities, on_delete: :nothing)
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create index(:branches, [
             :city_id,
             :business_id,
             :licence_issuing_authority_id,
             :country_id,
             :business_type_id,
             :status_id
           ])

    #    create unique_index(:branches, [:name])
    #    create unique_index(:branches, [:licence_no])
  end
end
