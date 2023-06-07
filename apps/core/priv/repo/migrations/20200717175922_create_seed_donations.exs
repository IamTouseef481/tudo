defmodule Core.Repo.Migrations.CreateSeedDonations do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "donations"
  @seeder "20200717160135_seed_donations"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
