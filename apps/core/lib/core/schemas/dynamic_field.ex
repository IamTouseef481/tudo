defmodule Core.Schemas.DynamicField do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "dynamic_fields" do
    field :title, :string
    field :alt, :string
    field :help_text, :string
    field :required_messages, {:array, :map}
    field :is_active, :boolean, default: false
    field :multi_selection, :boolean, default: false
    field :required, :boolean, default: false
    field :disabled, :boolean, default: false
    field :addable, :boolean, default: true
    field :editable, :boolean, default: true
    field :viewable, :boolean, default: true
    field :filterable, :boolean, default: false
    field :dynamic_field_order, :float, default: 0.0
    # "{single: '', multiple: [], key_value: {}}"
    field :fixed, :map
    # "{params: {}, uri: ''}"
    field :end_point_for_data, :map
    # "{select: [], table: '', where: {}}"
    field :query_for_data, :map
    field :dynamic_field_tag_id, :string
    field :dynamic_field_type_id, :string
    belongs_to :business, Core.Schemas.Business
    belongs_to :dynamic_group, Core.Schemas.DynamicGroup

    timestamps()
  end

  @doc false
  def changeset(dynamic_field, attrs) do
    dynamic_field
    |> cast(attrs, [
      :dynamic_group_id,
      :business_id,
      :title,
      :alt,
      :help_text,
      :required_messages,
      :dynamic_field_tag_id,
      :dynamic_field_type_id,
      :is_active,
      :multi_selection,
      :required,
      :disabled,
      :addable,
      :editable,
      :viewable,
      :filterable,
      :dynamic_field_order,
      :fixed,
      :end_point_for_data,
      :query_for_data
    ])
    |> validate_required([:title, :dynamic_group_id])
  end
end
