defmodule Core.Repo.Migrations.CreateSeedCountryServices do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "country_services"
  @seeder "20190902103722_seed_country_services"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
