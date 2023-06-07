defmodule Core.Repo.Migrations.CreateTudoSettings do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:tudo_settings) do
      add :title, :string
      add :slug, :string
      add :value, :float
      add :unit, :string
      add :is_active, :boolean, default: false, null: false
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create index(:tudo_settings, [:country_id])
  end
end
