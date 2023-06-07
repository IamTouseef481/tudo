defmodule TudoChat.Repo.Migrations.CreateSeedFriendsCircleStatuses do
  @moduledoc false
  use TudoChatWeb.Helpers.SeedHelper

  @table "friends_circle_statuses"
  @seeder "20190708091980_seed_table_friends_circle_statuses"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
