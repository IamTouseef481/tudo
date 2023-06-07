defmodule Core.Repo.Migrations.CreateTableEmployeeTypes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:employee_types, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
    end
  end
end
