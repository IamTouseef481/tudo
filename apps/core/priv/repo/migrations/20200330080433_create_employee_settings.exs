defmodule Core.Repo.Migrations.CreateEmployeeSettings do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:employee_settings) do
      add :wallet, :boolean, default: false, null: false
      add :qualification, :boolean, default: false, null: false
      add :experience, :boolean, default: false, null: false
      add :insurance, :boolean, default: false, null: false
      add :vehicle, :boolean, default: false, null: false
      add :family, :boolean, default: false, null: false
      add :employee_id, references(:employees, on_delete: :nothing)

      timestamps()
    end

    create index(:employee_settings, [:employee_id])
  end
end
