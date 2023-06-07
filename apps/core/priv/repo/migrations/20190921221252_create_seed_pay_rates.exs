defmodule Core.Repo.Migrations.CreateSeedPayRates do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "pay_rates"
  @seeder "20190921221252_seed_pay_rates"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
