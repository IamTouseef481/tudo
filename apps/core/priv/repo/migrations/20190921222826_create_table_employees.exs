defmodule Core.Repo.Migrations.CreateTableEmployees do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :contract_begin_date, :utc_datetime
      add :contract_end_date, :utc_datetime
      add :vehicle_details, :map
      add :pay_scale, :integer
      add :allowed_annual_ansence_hrs, :integer
      add :id_documents, :map
      add :personal_identification, :map
      add :terms_and_conditions, {:array, :integer}
      add :employee_role_in_org, :string
      add :photos, {:array, :map}
      add :current_location, :geometry
      add :manager_id, :integer
      add :approved_by_id, :integer
      add :approved_at, :utc_datetime
      add :branch_id, references(:branches, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :employee_role_id, references(:employee_roles, type: :varchar, on_delete: :nothing)
      add :employee_status_id, references(:employee_statuses, type: :varchar, on_delete: :nothing)
      add :employee_type_id, references(:employee_types, type: :varchar, on_delete: :nothing)
      add :shift_schedule_id, references(:shift_schedules, type: :varchar, on_delete: :nothing)
      add :pay_rate_id, references(:pay_rates, type: :varchar, on_delete: :nothing)

      timestamps()
    end

    create index(:employees, [:branch_id])
    create index(:employees, [:user_id])
    create index(:employees, [:employee_role_id])
    create index(:employees, [:employee_status_id])
    create index(:employees, [:employee_type_id])
    create index(:employees, [:shift_schedule_id])
    create index(:employees, [:pay_rate_id])
  end
end
