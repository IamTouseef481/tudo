defmodule Core.Repo.Migrations.CreateSeedLanguages do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "languages"
  @seeder "20190826064326_seed_languages"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
