defmodule Core.Repo.Migrations.AddSeedsForApplications do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "applications"
  @seeder "20230112083412_seed_applications"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
  end
end
