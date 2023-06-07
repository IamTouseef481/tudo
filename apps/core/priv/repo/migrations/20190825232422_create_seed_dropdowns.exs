defmodule Core.Repo.Migrations.CreateSeedDropdowns do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "dropdowns"
  @seeder "20190825232422_seed_dropdowns"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
