defmodule TudoChat.Repo.Migrations.SeedTableTenants do
  @moduledoc false
  use Ecto.Migration
  use SeedHelper

  @seeder "20190707091948_seed_table_tenants"

  def up do
    table = prefix <> ".tenants"
    import_from_csv(@seeder, &map_to_table(&1, table), true)
    reset_id_seq(table)
  end

  def down do
  end
end
