defmodule Core.Repo.Migrations.CreateSeedEmailCategories do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "email_categories"
  @seeder "20210519230133_seed_email_categories"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
