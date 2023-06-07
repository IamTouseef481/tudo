defmodule TudoChat.Repo.Migrations.SeedTableChannels do
  @moduledoc false
  use Ecto.Migration
  use SeedHelper

  @seeder "20190708091948_seed_table_channels"

  def up do
    if Application.get_env(:tudo_chat, :environment) != :prod do
      table = prefix <> ".channels"
      import_from_csv(@seeder, &map_to_table(&1, table), true)
      reset_id_seq(table)
    end
  end

  def down do
  end
end
