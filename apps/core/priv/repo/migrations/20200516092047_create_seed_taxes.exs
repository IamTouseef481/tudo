defmodule Core.Repo.Migrations.CreateSeedTaxes do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "taxes"
  @seeder "20200107230134_seed_taxes"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
