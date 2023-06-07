defmodule Core.Repo.Migrations.CreateSeedPromotionStatuses do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "promotion_statuses"
  @seeder "20200107230133_seed_promotion_statuses"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #        reset_id_seq(@table)
  end

  def down do
  end
end
