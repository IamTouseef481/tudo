defmodule Core.Repo.Migrations.CreateSeedUnits do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "units"
  @seeder "20200816230136_seed_units"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
