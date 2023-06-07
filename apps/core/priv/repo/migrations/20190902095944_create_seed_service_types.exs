defmodule Core.Repo.Migrations.CreateSeedServiceTypes do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "service_types"
  @seeder "20190902095944_seed_service_types"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
