defmodule TudoChat.Repo.Migrations.CreateSeedGroupMemberRoles do
  @moduledoc false
  use TudoChatWeb.Helpers.SeedHelper

  @table "group_member_roles"
  @seeder "20190708091970_seed_table_group_member_roles"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
