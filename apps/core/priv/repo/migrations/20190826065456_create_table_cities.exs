defmodule Core.Repo.Migrations.CreateTableCities do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:cities) do
      add :name, :string
      add :short_code, :string
      add :details, :map
      add :zip, :string
      add :search_vector, :tsvector
      add :state_id, references(:states, on_delete: :nothing)

      timestamps()
    end

    create index(:cities, [:state_id])
  end
end
