defmodule Core.Repo.Migrations.CreateSeedStates do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "states"
  @seeder "20190826064828_seed_states"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
