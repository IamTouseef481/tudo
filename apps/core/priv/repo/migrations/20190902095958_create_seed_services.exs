defmodule Core.Repo.Migrations.CreateSeedServices do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "services"
  @seeder "20190902095958_seed_services"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
