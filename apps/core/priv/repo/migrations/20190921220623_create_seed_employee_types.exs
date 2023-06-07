defmodule Core.Repo.Migrations.CreateSeedEmployeeTypes do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "employee_types"
  @seeder "20190921220623_seed_employee_types"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
