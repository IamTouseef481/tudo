defmodule Core.Repo.Migrations.CreateSeedBusinessTermsAndConditions do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "business_terms_and_conditions"
  @seeder "20190825233240_seed_business_terms_and_conditions"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
