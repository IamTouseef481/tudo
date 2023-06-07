defmodule Core.Repo.Migrations.CreateTableServiceSettings do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:service_settings) do
      add :fields, :map
      add :country_service_id, references(:country_services, on_delete: :nothing)

      timestamps()
    end

    create index(:service_settings, [:country_service_id])
  end
end
