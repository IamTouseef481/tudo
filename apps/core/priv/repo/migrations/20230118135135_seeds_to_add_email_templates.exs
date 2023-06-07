defmodule Core.Repo.Migrations.SeedsToAddEmailTemplates do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "email_templates"
  @seeder "20230118135135_seed_email_template"
  def change do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end
end
