defmodule Core.Repo.Migrations.CreateTableEmployeeServices do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:employee_services) do
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :branch_service_id, references(:branch_services, on_delete: :nothing)
      add :employee_id, references(:employees, on_delete: :nothing)

      timestamps()
    end

    create index(:employee_services, [:branch_service_id])
    create index(:employee_services, [:employee_id])
  end
end
