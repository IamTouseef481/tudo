defmodule Tudo.Repo.Migrations.CreateTableDynamicGroups do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "dynamic_groups"
  @seeder "20190921223408_seed_dynamic_groups"
  def change do
    create table(@table) do
      add :name, :string, null: false
      add :description, :text
      add :business_id, references(:businesses, on_delete: :delete_all)
      timestamps()
    end

    create index(@table, [:name, :business_id])

    import_from_csv(@seeder, &map_to_table(&1, @table), true)
    reset_id_seq(@table)
  end
end
