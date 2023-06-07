defmodule Core.Repo.Migrations.CreateSeedScreens do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "screens"
  @seeder "20200626160134_seed_screens"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
