defmodule Core.Repo.Migrations.CreateSeedJobCategories do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "job_categories"
  @seeder "20191113175718_seed_job_categories"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
