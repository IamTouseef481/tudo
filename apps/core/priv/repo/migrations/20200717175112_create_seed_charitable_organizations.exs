defmodule Core.Repo.Migrations.CreateSeedCharitableOrganizations do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "charitable_organizations"
  @seeder "20200717160134_seed_charitable_organizations"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
