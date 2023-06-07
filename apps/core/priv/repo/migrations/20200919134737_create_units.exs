defmodule Core.Repo.Migrations.CreateUnits do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:units) do
      add :name, :string
      add :slug, :string
      add :code, :string
      add :description, :text
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create index(:units, [:country_id])
  end
end
