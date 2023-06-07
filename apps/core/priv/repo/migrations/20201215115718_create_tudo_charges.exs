defmodule Core.Repo.Migrations.CreateTudoCharges do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:tudo_charges) do
      add :name, :string
      add :slug, :string
      add :value, :float
      add :is_percentage, :boolean, default: true, null: false
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create index(:tudo_charges, [:country_id])
  end
end
