defmodule Core.Repo.Migrations.CreateTableServiceGroups do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "service_groups"
  @seeder "20190902000114_seed_service_groups"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
