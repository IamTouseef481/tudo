defmodule Core.Repo.Migrations.CreateSeedAdminNotificationSettings do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "admin_notification_settings"
  @seeder "20210903070501_seed_admin_notification_settings"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
