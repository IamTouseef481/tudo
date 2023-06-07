defmodule Core.Repo.Migrations.CreateTableBranchServices do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:branch_services) do
      add :is_active, :boolean, default: false, null: false
      add :auto_assign, :boolean, default: false, null: false
      add :branch_id, references(:branches, on_delete: :nothing)
      add :country_service_id, references(:country_services, on_delete: :nothing)
      add :service_type_id, references(:service_types, type: :varchar, on_delete: :nothing)

      timestamps()
    end

    create index(:branch_services, [:country_service_id, :branch_id, :service_type_id])
  end
end
