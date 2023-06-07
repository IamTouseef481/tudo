defmodule CoreWeb.GraphQL.Types.EmailSettingType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :email_setting_type do
    field :id, non_null(:id)
    field :slug, :string
    field :title, :string
    field :is_active, :boolean
    field :category, :category_type, resolve: assoc(:category)
    field :user, :user_type, resolve: assoc(:user)
  end

  object :category_type do
    field :id, non_null(:string)
    field :description, :string
  end

  input_object :email_setting_update_type do
    field :slug, :string
    field :is_active, :boolean
    field :category_id, :string
  end
end
