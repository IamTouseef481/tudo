defmodule Core.Repo.Migrations.CreateSeedBusinessTypes do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "business_types"
  @seeder "20190825232424_seed_business_types"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
