defmodule Core.Repo.Migrations.CreateSeedMenus do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "menus"
  @seeder "20190925043014_seed_menus"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
