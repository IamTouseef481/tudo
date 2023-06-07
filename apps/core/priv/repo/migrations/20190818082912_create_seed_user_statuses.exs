defmodule Core.Repo.Migrations.CreateSeedUserStatuses do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "user_statuses"
  @seeder "20190818082912_seed_user_statuses"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
