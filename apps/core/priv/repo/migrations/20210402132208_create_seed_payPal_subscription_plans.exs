defmodule Core.Repo.Migrations.CreateSeedPaypalSubscriptionPlans do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "paypal_subscription_plans"
  @seeder "20210412230136_seed_paypal_subscription_plans"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
