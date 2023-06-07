defmodule Tudo.Repo.Migrations.CreateTableDynamicScreens do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "dynamic_screens"
  @seeder "20190921223409_seed_dynamic_screens"
  def change do
    create table(@table) do
      add :name, :string, null: false
      add :description, :text
      add :dynamic_screen_order, :float, default: 0.0
      add :addable, :boolean, default: true, null: false
      add :editable, :boolean, default: true, null: false
      add :viewable, :boolean, default: true, null: false
      add :filterable, :boolean, default: false, null: false
      add :help_text, :string
      add :country_service_id, references(:country_services, on_delete: :nothing), null: false
      add :business_id, references(:businesses, on_delete: :delete_all)

      timestamps()
    end

    create index(@table, [:country_service_id, :business_id])

    import_from_csv(@seeder, &map_to_table(&1, @table), true)
    reset_id_seq(@table)
  end
end
