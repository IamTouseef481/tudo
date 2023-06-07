defmodule Core.Repo.Migrations.CreateSeedEmployeeRoles do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "employee_roles"
  @seeder "20190921220059_seed_employee_roles"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
