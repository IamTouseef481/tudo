defmodule Core.Repo.Migrations.CreateSeedTudoCharges do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "tudo_charges"
  @seeder "20201215230136_seed_tudo_charges"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
