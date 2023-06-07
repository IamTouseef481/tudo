defmodule CoreWeb.GraphQL.Types.NotificationType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :push_notification_type do
    field :id, :integer
    field :title, :string
    field :description, :string
    field :read, :boolean
    field :pushed_at, :datetime
    field :acl_role_id, :string
    field :user, :user_type, resolve: assoc(:user)
    field :branch, :branch_type, resolve: assoc(:branch)
  end

  object :admin_email_notification_settings_type do
    field :id, :integer
    field :event, :string
    field :slug, :string
    field :cmr_email, :boolean
    field :bsp_email, :boolean
    field :cmr_notification, :boolean
    field :bsp_notification, :boolean
    field :category, :category_type, resolve: assoc(:category)
  end

  input_object :push_notification_get_by_role_type do
    field :acl_role_id, non_null(:string)
    field :branch_id, :integer
    field :read, :boolean
  end

  input_object :push_notification_update_type do
    field :notification_ids, non_null(list_of(:integer))
    field :read, non_null(:boolean)
  end

  input_object :admin_email_notification_settings_update_type do
    field :id, non_null(:integer)
    field :event, :string
    field :slug, :string
    field :cmr_email, :boolean
    field :bsp_email, :boolean
    field :cmr_notification, :boolean
    field :bsp_notification, :boolean
    field :category_id, :string
  end
end
