defmodule Core.Repo.Migrations.CreateTableApplications do
  use Ecto.Migration

  def change do
    create table(:applications, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
    end
  end
end
