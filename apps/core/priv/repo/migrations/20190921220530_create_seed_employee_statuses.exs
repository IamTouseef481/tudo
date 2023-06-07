defmodule Core.Repo.Migrations.CreateSeedEmployeeStatuses do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "employee_statuses"
  @seeder "20190921220530_seed_employee_statuses"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
