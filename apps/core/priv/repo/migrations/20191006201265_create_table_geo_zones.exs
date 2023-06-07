defmodule Core.Repo.Migrations.CreateTableGeoZones do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:geo_zones) do
      add(:title, :string)
      add(:slug, :string)
      add(:description, :string)
      add :city_id, references(:cities, on_delete: :nothing)
      add :state_id, references(:states, on_delete: :nothing)
      add :country_id, references(:countries, on_delete: :nothing)
      add(:status_id, :string)
      add(:coordinates, :"geometry(POLYGON,4326)")
    end

    create(index(:geo_zones, [:status_id]))
    create(index(:geo_zones, [:coordinates]))
    create index(:geo_zones, [:city_id])
    create index(:geo_zones, [:state_id])
    create index(:geo_zones, [:country_id])
  end
end
