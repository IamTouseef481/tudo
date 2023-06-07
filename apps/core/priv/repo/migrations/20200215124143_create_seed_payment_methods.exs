defmodule Core.Repo.Migrations.CreateSeedPaymentMethods do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "payment_methods"
  @seeder "20190902095944_seed_payment_methods"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
