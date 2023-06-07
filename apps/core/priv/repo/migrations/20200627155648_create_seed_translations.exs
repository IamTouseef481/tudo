defmodule Core.Repo.Migrations.CreateSeedTranslations do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "translations"
  @seeder "20200626160234_seed_translations"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
