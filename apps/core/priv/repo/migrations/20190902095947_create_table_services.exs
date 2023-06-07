defmodule Core.Repo.Migrations.CreateTableServices do
  @moduledoc false
  use Ecto.Migration
  @table :services
  def change do
    create table(@table) do
      add :name, :string
      add :service_group_id, references(:service_groups, on_delete: :nothing)
      add :service_type_id, references(:service_types, type: :varchar, on_delete: :nothing)
      add :service_status_id, references(:service_statuses, type: :varchar, on_delete: :nothing)

      timestamps()
    end

    create index(@table, [:service_group_id, :service_type_id, :service_status_id])
  end
end
