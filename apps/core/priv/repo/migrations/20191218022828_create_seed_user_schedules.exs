defmodule Core.Repo.Migrations.CreateSeedUserSchedules do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  # @table "user_schedules"
  # @seeder "20191218022828_seed_user_schedules"

  def up do
    #    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
