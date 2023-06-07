defmodule Core.Repo.Migrations.CreateSeedServiceSettings do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "service_settings"
  @seeder "20190902000115_seed_service_settings"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
