defmodule Core.Repo.Migrations.CreateTableEmployeeStatuses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:employee_statuses, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string

      timestamps()
    end
  end
end
