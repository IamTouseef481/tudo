defmodule TudoChatWeb.GraphQL.Types.SettingType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :setting_type do
    field :id, :integer
    field :title, :string
    field :slug, :string
    field :type, :string
    field :user_id, :integer
    field :fields, :json
  end

  object :group_setting_type do
    field :id, :integer
    field :title, :string
    field :slug, :string
    field :user_id, :integer
    field :fields, :json
  end

  input_object :setting_get_type do
    field :type, :string
    field :user_id, :integer
  end

  input_object :setting_input_type do
    field :title, :string
    field :slug, non_null(:string)
    field :type, :string
    field :fields, :string
  end

  input_object :setting_update_type do
    field :setting_id, non_null(:integer)
    field :title, :string
    field :slug, :string
    field :type, :string
    #    field :user_id, :integer
    field :fields, :string
  end

  input_object :group_setting_get_type do
    field :group_id, non_null(:integer)
    field :user_id, :integer
  end

  input_object :group_setting_input_type do
    field :title, :string
    field :slug, non_null(:string)
    field :fields, :string
    field :group_id, non_null(:integer)
  end

  input_object :group_setting_update_type do
    field :setting_id, non_null(:integer)
    field :title, :string
    field :slug, :string
    #    field :user_id, :integer
    field :fields, :string
  end
end
