defmodule Core.Repo.Migrations.CreateSeedEmailTemplates do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "email_templates"
  @seeder "20190830222250_seed_email_templates"

  def up do
    #    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end

  def down do
  end
end
