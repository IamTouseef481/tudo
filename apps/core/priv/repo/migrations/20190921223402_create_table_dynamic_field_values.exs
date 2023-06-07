defmodule Core.Repo.Migrations.CreateTableDynamicFieldValues do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "dynamic_field_values"
  @seeder "20190921223402_seed_dynamic_field_values"

  def change do
    create table(@table) do
      add :fixed, :map, comment: "{single: '', multiple: [], key_value: {}}"
      add :end_point, :map, comment: "{params: {}, uri: ''}"
      add :query, :map, comment: "{select: [], table: '', where: {}}"
    end

    import_from_csv(@seeder, &map_to_table(&1, @table))
    #    reset_id_seq(@table)
  end
end
