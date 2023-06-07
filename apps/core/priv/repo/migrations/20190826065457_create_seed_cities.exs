defmodule Core.Repo.Migrations.CreateSeedCities do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  # @table "cities"
  # @seeder "20190826065457_seed_cities"

  def up do
    #    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
