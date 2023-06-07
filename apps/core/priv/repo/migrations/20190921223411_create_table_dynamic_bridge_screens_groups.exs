defmodule Tudo.Repo.Migrations.CreateTableDynamicBridgeScreensGroups do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "bridge_screens_groups"
  @seeder "20190921223411_seed_dynamic_bridge_screens_groups"
  def change do
    create table(@table) do
      add :dynamic_group_order, :float, default: 0.0
      add :dynamic_screen_id, references(:dynamic_screens, on_delete: :delete_all)
      add :dynamic_group_id, references(:dynamic_groups, on_delete: :delete_all)
    end

    create index(@table, [:dynamic_screen_id, :dynamic_group_id, :dynamic_group_order])

    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end
end
