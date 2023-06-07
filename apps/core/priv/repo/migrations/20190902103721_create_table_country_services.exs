defmodule Core.Repo.Migrations.CreateTableCountryServices do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:country_services) do
      add :is_active, :boolean, default: false, null: true
      add :country_id, references(:countries, on_delete: :nothing)
      add :service_id, references(:services, on_delete: :nothing)
      add :dynamic_field_id, :integer
      #      add :dynamic_field_id, references(:dynamic_fields, on_delete: :nothing)

      timestamps()
    end

    create index(:country_services, [:country_id])
    create index(:country_services, [:service_id])
    #    create index(:country_services, [:dynamic_field_id])
  end
end
