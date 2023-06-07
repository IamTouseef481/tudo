defmodule Core.Repo.Migrations.CreateTableDropdowns do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:dropdowns) do
      add :name, :string
      add :slug, :string
      add :type, :string
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create index(:dropdowns, [:country_id])
  end
end
