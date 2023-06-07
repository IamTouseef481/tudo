defmodule Core.Repo.Migrations.CreateSeedPaymentsStatuses do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "payment_statuses"
  @seeder "20200816230135_seed_payment_statuses"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #        reset_id_seq(@table)
  end

  def down do
  end
end
