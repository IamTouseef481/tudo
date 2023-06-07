defmodule TudoChat.Repo.Migrations.CreateSeedJobStatuses do
  @moduledoc false
  use TudoChatWeb.Helpers.SeedHelper

  @table "job_statuses"
  @seeder "20191113175720_seed_job_statuses"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
