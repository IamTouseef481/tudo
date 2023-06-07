defmodule Core.Repo.Migrations.CreateTableSettings do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :title, :string
      add :slug, :string
      add :type, :string
      add :branch_id, references(:branches, on_delete: :nothing)
      add :fields, :map

      timestamps()
    end

    create index(:settings, [:branch_id])
  end
end
