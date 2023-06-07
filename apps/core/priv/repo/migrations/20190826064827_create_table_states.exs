defmodule Core.Repo.Migrations.CreateTableStates do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:states) do
      add :name, :string
      add :short_code, :string
      add :capital, :string
      add :fips_code, :string
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create index(:states, [:country_id])
    create unique_index(:states, [:short_code])
  end
end
