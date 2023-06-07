defmodule Core.Repo.Migrations.CreateSeedTudoSettings do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "tudo_settings"
  @seeder "20210804070501_seed_tudo_settings"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
