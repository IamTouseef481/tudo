defmodule Core.Repo.Migrations.CreateTableDynamicFieldTypes do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "dynamic_field_types"
  @seeder "20190921223404_seed_dynamic_field_types"

  def change do
    create table(@table, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
    end

    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end
end
