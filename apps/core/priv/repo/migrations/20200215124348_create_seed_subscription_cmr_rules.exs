defmodule Core.Repo.Migrations.CreateSeedCMRSubscriptionRules do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "subscription_cmr_rules"
  @seeder "20200816230134_seed_cmr_subscription_rules"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
