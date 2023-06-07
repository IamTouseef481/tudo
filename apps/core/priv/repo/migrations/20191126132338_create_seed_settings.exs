defmodule Core.Repo.Migrations.CreateSeedSettings do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  # @table "settings"
  # @seeder "20191126132338_seed_settings"

  def up do
    #    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
