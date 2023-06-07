defmodule Core.Repo.Migrations.CreateSeedAclRoles do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "acl_roles"
  @seeder "20190927031703_seed_acl_roles"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
