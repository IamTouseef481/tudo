defmodule Core.Repo.Migrations.CreateSeedMenuRoles do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "menu_roles"
  @seeder "20190927031709_seed_menu_roles"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
