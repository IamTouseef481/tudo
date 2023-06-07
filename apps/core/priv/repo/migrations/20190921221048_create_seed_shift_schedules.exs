defmodule Core.Repo.Migrations.CreateSeedShiftSchedules do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "shift_schedules"
  @seeder "20190921221048_seed_shift_schedules"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
