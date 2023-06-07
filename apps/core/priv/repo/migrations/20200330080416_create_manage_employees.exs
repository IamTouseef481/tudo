defmodule Core.Repo.Migrations.CreateManageEmployees do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:manage_employees) do
      add :employee_id, references(:employees, on_delete: :nothing)
      add :manager_id, references(:employees, on_delete: :nothing)

      timestamps()
    end

    create index(:manage_employees, [:employee_id, :manager_id])
  end
end
