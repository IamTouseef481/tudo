defmodule Core.Repo.Migrations.CreateSeedPlatformTermsAndConditions do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "platform_terms_and_conditions"
  @seeder "20190819030300_seed_platform_terms_and_conditions"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
