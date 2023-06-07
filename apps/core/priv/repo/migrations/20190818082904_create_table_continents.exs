defmodule Core.Repo.Migrations.CreateTableContinents do
  use Ecto.Migration

  def change do
    create table(:continents) do
      add :code, :string
      add :name, :string

      timestamps()
    end
  end
end
