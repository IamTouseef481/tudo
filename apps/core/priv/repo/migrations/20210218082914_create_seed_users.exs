defmodule Core.Repo.Migrations.CreateSeedUsers do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "users"
  @seeder "20190818082912_seed_users"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
