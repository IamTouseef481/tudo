defmodule Core.Repo.Migrations.CreateSeedBranchServices do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "branch_services"
  @seeder "20190916013158_seed_branch_services"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
