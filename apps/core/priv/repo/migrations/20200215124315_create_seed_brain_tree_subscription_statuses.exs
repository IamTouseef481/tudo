defmodule Core.Repo.Migrations.CreateSeedBrainTreeSubscriptionStatuses do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "brain_tree_subscription_statuses"
  @seeder "20200813230133_seed_brain_tree_subscription_statuses"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
