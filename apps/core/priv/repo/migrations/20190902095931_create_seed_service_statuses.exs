defmodule Core.Repo.Migrations.CreateSeedServiceStatuses do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "service_statuses"
  @seeder "20190902095931_seed_service_statuses"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #        reset_id_seq(@table)
  end

  def down do
  end
end
