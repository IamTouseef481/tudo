defmodule Core.Repo.Migrations.CreateTableDynamicFields do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "dynamic_fields"
  @seeder "20190921223406_seed_dynamic_fields"

  def change do
    create table(@table) do
      add :title, :string
      add :description, :text
      add :alt, :string
      add :help_text, :string
      add :required_messages, {:array, :map}
      add :is_active, :boolean, default: false, null: false
      add :multi_selection, :boolean, default: false, null: false
      add :required, :boolean, default: false, null: false
      add :disabled, :boolean, default: false, null: false
      add :addable, :boolean, default: true, null: false
      add :editable, :boolean, default: true, null: false
      add :viewable, :boolean, default: true, null: false
      add :filterable, :boolean, default: false, null: false
      add :dynamic_field_order, :float, default: 0.0
      add :fixed, :map, comment: "{single: '', multiple: [], key_value: {}}"
      add :end_point_for_data, :map, comment: "{params: {}, uri: ''}"
      add :query_for_data, :map, comment: "{select: [], table: '', where: {}}"

      add :dynamic_field_tag_id,
          references(:dynamic_field_tags,
            type: :varchar,
            on_delete: :delete_all,
            on_update: :update_all
          ),
          null: false

      add :dynamic_field_type_id,
          references(:dynamic_field_types,
            type: :varchar,
            on_delete: :delete_all,
            on_update: :update_all
          ),
          null: false

      add :dynamic_group_id, references(:dynamic_groups, on_delete: :delete_all), null: false
      add :business_id, references(:businesses, on_delete: :delete_all)

      timestamps()
    end

    create index(@table, [
             :dynamic_group_id,
             :dynamic_field_tag_id,
             :dynamic_field_type_id,
             :business_id
           ])

    import_from_csv(@seeder, &map_to_table(&1, @table), true)
    reset_id_seq(@table)
  end
end
