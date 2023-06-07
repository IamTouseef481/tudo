defmodule Core.Repo.Migrations.CreateSeedBSPSubscriptionRules do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "subscription_bsp_rules"
  @seeder "20200816230133_seed_bsp_subscription_rules"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
