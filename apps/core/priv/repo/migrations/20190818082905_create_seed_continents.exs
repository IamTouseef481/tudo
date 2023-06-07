defmodule Core.Repo.Migrations.CreateSeedContinents do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "continents"
  @seeder "20190826064107_seed_continents"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
