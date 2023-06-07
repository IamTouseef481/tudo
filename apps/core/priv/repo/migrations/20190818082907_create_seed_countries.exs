defmodule Core.Repo.Migrations.CreateSeedCountries do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "countries"
  @seeder "20190826064752_seed_countries"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
