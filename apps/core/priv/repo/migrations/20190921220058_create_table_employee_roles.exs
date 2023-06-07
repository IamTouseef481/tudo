defmodule Core.Repo.Migrations.CreateTableEmployeeRoles do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:employee_roles, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string

      timestamps()
    end
  end
end
