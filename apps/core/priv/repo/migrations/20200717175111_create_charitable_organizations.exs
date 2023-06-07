defmodule Core.Repo.Migrations.CreateCharitableOrganizations do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:charitable_organizations) do
      add :name, :string
      add :phone, :string
      add :licence_no, :string
      add :licence_photos, {:array, :map}
      add :licence_expiry_date, :utc_datetime
      add :personal_identification, :map
      add :profile_pictures, {:array, :map}
      add :employees_count, :integer
      add :settings, :map
      add :est_year, :utc_datetime
      add :address, :map
      add :zone_ids, {:array, :integer}
      add :location, :geometry
      add :is_active, :boolean, default: false, null: false
      add :rating, :float

      add :licence_issuing_authority_id,
          references(:licence_issuing_authorities, on_delete: :nothing)

      add :city_id, references(:cities, on_delete: :nothing)

      timestamps()
    end

    create index(:charitable_organizations, [:licence_issuing_authority_id])
    create index(:charitable_organizations, [:city_id])
  end
end
