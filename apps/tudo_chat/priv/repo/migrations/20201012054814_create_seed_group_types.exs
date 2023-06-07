defmodule TudoChat.Repo.Migrations.CreateSeedGroupTypes do
  @moduledoc false
  use TudoChatWeb.Helpers.SeedHelper

  @table "group_types"
  @seeder "20190708091948_seed_table_group_types"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
