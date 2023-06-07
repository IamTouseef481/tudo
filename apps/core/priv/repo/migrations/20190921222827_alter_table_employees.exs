defmodule Core.Repo.Migrations.AlterTableEmployees do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter(table(:employees)) do
      modify(:manager_id, references(:employees, on_delete: :nothing))
      modify(:approved_by_id, references(:employees, on_delete: :nothing))
    end

    create(index(:employees, [:approved_by_id]))
    create index(:employees, [:manager_id])
  end
end
