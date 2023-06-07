defmodule Core.Repo.Migrations.CreateSeedBranches do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  # @table "branches"
  # @seeder "20190826073529_seed_branches"

  def up do
    #    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
