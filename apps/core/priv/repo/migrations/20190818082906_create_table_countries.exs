defmodule Core.Repo.Migrations.CreateTableCountries do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:countries) do
      add :name, :string
      add :official_name, :string
      add :capital, :string
      add :code, :string
      add :nmc_code, :string
      add :isd_code, :string
      add :currency_code, :string
      add :currency_symbol, :string
      add :is_active, :boolean, default: false, null: false
      add :contact_info, :map
      add :unit_system, :map
      add :language_id, references(:languages, on_delete: :nothing)
      add :continent_id, references(:continents, on_delete: :nothing)

      timestamps()
    end

    create index(:countries, [:language_id])
    create index(:countries, [:continent_id])
  end
end
