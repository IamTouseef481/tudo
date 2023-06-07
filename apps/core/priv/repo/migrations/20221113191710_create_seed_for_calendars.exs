defmodule Core.Repo.Migrations.CreateSeedForCalendars do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "calendars"
  @seeder "20191113191701_seed_calendars"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
