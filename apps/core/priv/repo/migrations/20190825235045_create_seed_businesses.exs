defmodule Core.Repo.Migrations.CreateSeedBusinesses do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  # @table "businesses"
  # @seeder "20190825235045_seed_businesses"

  def up do
    #    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
