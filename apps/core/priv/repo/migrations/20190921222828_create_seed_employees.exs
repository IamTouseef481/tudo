defmodule Core.Repo.Migrations.CreateSeedEmployees do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  # @table "employees"
  # @seeder "20190921222827_seed_employees"

  def up do
    #    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
