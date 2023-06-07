defmodule CoreWeb.GraphQL.Types.DynamicType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :dynamic_screen_type do
    field :id, :integer
    field :name, :string
    field :description, :string
    field :dynamic_screen_order, :float
    field :addable, :boolean
    field :editable, :boolean
    field :viewable, :boolean
    field :filterable, :boolean
    field :help_text, :string
    field :country_service, :country_service_type, resolve: assoc(:country_service)
    field :business, :business_type, resolve: assoc(:business)
    field :dynamic_group, list_of(:dynamic_group_type)
  end

  object :dynamic_field_type do
    field :id, :id
    field :title, :string
    field :alt, :string
    field :help_text, :string
    field :required_messages, list_of(:json)
    field :dynamic_field_order, :float
    field :is_active, :boolean
    field :multi_selection, :boolean
    field :required, :boolean
    field :disabled, :boolean
    field :addable, :boolean
    field :editable, :boolean
    field :viewable, :boolean
    field :filterable, :boolean
    field :fixed, :json
    field :end_point_for_data, :json
    field :query_for_data, :json
    field :dynamic_field_tag_id, :string
    field :dynamic_field_type_id, :string
    field :business, :business_type, resolve: assoc(:businesss)
    #    field :dynamic_group, :dynamic_group_type, resolve: assoc(:dynamic_group)
  end

  object :dynamic_group_type do
    field :id, :integer
    field :name, :string
    field :description, :string
    field :dynamic_group_order, :float
    field :business, :business_type, resolve: assoc(:business)
    field :dynamic_field, list_of(:dynamic_field_type)
    field :dynamic_screen, :dynamic_screen_type, resolve: assoc(:dynamic_screen)
  end

  object :attach_existing_dynamic_group_type do
    field :id, :integer
    field :dynamic_group_order, :float
    field :dynamic_screen, :dynamic_screen_type, resolve: assoc(:dynamic_screen)
    field :dynamic_group, :dynamic_group_type, resolve: assoc(:dynamic_group)
  end

  object :dynamic_field_tag_type do
    field :id, :id
    field :description, :string
  end

  object :dynamic_field_type_type do
    field :id, :id
    field :description, :string
  end

  object :dynamic_field_value_type do
    field :id, :id
    field :fixed, :json
    field :end_point, :json
    field :query, :json
  end

  #
  #  input_object :dynamic_group_input_type do
  #    field :is_active, :boolean, default: false
  #    field :multi_selection, :boolean, default: false
  #    field :required, :boolean, default: false
  #    field :disabled, :boolean, default: false
  #    field :addable, :boolean, default: true
  #    field :editable, :boolean, default: true
  #    field :viewable, :boolean, default: true
  #    field :filterable, :boolean, default: false
  #    field :fixed, :fixed_type # "{single: '', multiple: [], key_value: {}}"
  #    field :end_point_for_data, :end_point_for_data_type # "{params: {}, uri: ''}"
  #    field :query_for_data, :query_for_data_type # "{select: [], table: '', where: {}}"
  #    field :dynamic_field_tags_id, :integer
  #    field :dynamic_field_type_id, :integer
  #  end
  #
  #  input_object :fixed_type do
  #    field :single, :integer
  #    field :multiple, list_of(:integer)
  #    field :, :
  #  end
  #    input_object :end_point_for_data_type do
  #      field :uri, :string
  #      field :params, :params_type
  #    end
  #    input_object :query_for_data_type do
  #      field :select, list_of(:string)
  #      field :table, :string
  #      field :where, :where_type
  #    end
  #    input_object :params_type do
  #      field :, :
  #    field :, :
  #  end
  #
  #  input_object :dynamic_field_input_type do
  #    field :is_active, :boolean, default: false
  #    field :multi_selection, :boolean, default: false
  #    field :required, :boolean, default: false
  #    field :disabled, :boolean, default: false
  #    field :addable, :boolean, default: true
  #    field :editable, :boolean, default: true
  #    field :viewable, :boolean, default: true
  #    field :filterable, :boolean, default: false
  #    field :fixed, :fixed_type # "{single: '', multiple: [], key_value: {}}"
  #    field :end_point_for_data, :end_point_for_data_type # "{params: {}, uri: ''}"
  #    field :query_for_data, :query_for_data_type # "{select: [], table: '', where: {}}"
  #    field :dynamic_field_tags_id, :integer
  #    field :dynamic_field_type_id, :integer
  #  end
  #
  #  input_object :fixed_type do
  #    field :single, :integer
  #    field :multiple, list_of(:integer)
  #    field :, :
  #  end
  #  input_object :end_point_for_data_type do
  #    field :uri, :string
  #    field :params, :params_type
  #  end
  #  input_object :query_for_data_type do
  #    field :select, list_of(:string)
  #    field :table, :string
  #    field :where, :where_type
  #  end
  #  input_object :params_type do
  #    field :, :
  #    field :, :
  #  end

  input_object :dynamic_screen_get_type do
    field :country_service_ids, list_of(:integer)
    field :country_service_id, :integer
    field :business_id, non_null(:integer)
  end

  input_object :dynamic_group_get_type do
    field :dynamic_screen_id, non_null(:integer)
    field :business_id, non_null(:integer)
  end

  input_object :dynamic_field_get_type do
    field :dynamic_group_id, non_null(:integer)
    field :business_id, non_null(:integer)
  end

  input_object :dynamic_screen_input_type do
    field :name, non_null(:string)
    field :description, :string
    field :dynamic_screen_order, non_null(:float)
    field :addable, :boolean
    field :editable, :boolean
    field :viewable, :boolean
    field :filterable, :boolean
    field :help_text, :string
    field :country_service_id, non_null(:integer)
    field :business_id, :integer
  end

  input_object :dynamic_group_input_type do
    field :name, non_null(:string)
    field :description, :string
    field :dynamic_group_order, non_null(:float)
    field :business_id, :integer
    field :dynamic_screen_id, non_null(:integer)
  end

  input_object :attach_existing_dynamic_group_input_type do
    field :dynamic_group_id, non_null(:integer)
    field :dynamic_screen_id, non_null(:integer)
    field :dynamic_group_order, non_null(:float)
  end

  input_object :dynamic_group_update_type do
    field :id, non_null(:id)
    field :name, :string
    field :description, :string
    field :dynamic_group_order, :float
    field :business_id, :integer
    field :dynamic_screen_id, non_null(:integer)
    field :new_dynamic_screen_id, :integer
    field :new_dynamic_group_id, :integer
  end

  input_object :dynamic_field_input_type do
    field :title, :string
    field :alt, :string
    field :help_text, :string
    field :required_messages, list_of(:required_messages)
    field :dynamic_screen_order, :float
    field :is_active, :boolean
    field :multi_selection, :boolean
    field :required, :boolean
    field :disabled, :boolean
    field :addable, :boolean
    field :editable, :boolean
    field :viewable, :boolean
    field :filterable, :boolean
    field :dynamic_field_order, non_null(:float)
    field :fixed, :string
    field :end_point_for_data, :end_point_for_data
    field :query_for_data, :query_for_data_type
    field :dynamic_group_id, :id
    field :dynamic_field_tag_id, :string
    field :dynamic_field_type_id, :string
    field :business_id, :integer
  end

  input_object :dynamic_field_update_type do
    field :id, :id
    field :title, :string
    field :alt, :string
    field :help_text, :string
    field :required_messages, list_of(:required_messages)
    field :dynamic_screen_order, :float
    field :is_active, :boolean
    field :multi_selection, :boolean
    field :required, :boolean
    field :disabled, :boolean
    field :addable, :boolean
    field :editable, :boolean
    field :viewable, :boolean
    field :filterable, :boolean
    field :dynamic_field_order, :float
    field :fixed, :string
    field :end_point_for_data, :end_point_for_data
    field :query_for_data, :query_for_data_type
    field :dynamic_group_id, :id
    field :dynamic_field_tag_id, :string
    field :dynamic_field_type_id, :string
    field :business_id, :integer
  end

  input_object :required_messages do
    field :message_for, :string
    field :message, :string
  end

  input_object :end_point_for_data do
    field :uri, :string
    field :params, :string
  end

  input_object :params_type do
    field :a, :string
    field :b, :string
  end

  input_object :query_for_data_type do
    field :select, list_of(:string)
    field :table, :string
    field :where, :string
  end

  input_object :dynamic_screen_update_type do
    field :id, non_null(:integer)
    field :name, :string
    field :description, :string
    field :dynamic_screen_order, :float
    field :addable, :boolean
    field :editable, :boolean
    field :viewable, :boolean
    field :filterable, :boolean
    field :help_text, :string
    field :country_service_id, :integer
    field :business_id, :integer
  end

  input_object :dynamic_screen_delete_type do
    field :id, non_null(:integer)
  end

  input_object :dynamic_group_delete_type do
    field :id, non_null(:integer)
  end

  input_object :dynamic_field_tag_input_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :dynamic_field_tag_update_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :dynamic_field_tag_get_type do
    field :id, non_null(:id)
  end

  input_object :dynamic_field_type_input_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :dynamic_field_type_update_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :dynamic_field_type_get_type do
    field :id, non_null(:id)
  end

  input_object :dynamic_field_value_input_type do
    field :fixed, :string
    field :end_point, :string
    field :query, :string
  end

  input_object :dynamic_field_value_update_type do
    field :id, non_null(:id)
    field :fixed, :string
    field :end_point, :string
    field :query, :string
  end

  input_object :dynamic_field_value_get_type do
    field :id, non_null(:id)
  end
end
