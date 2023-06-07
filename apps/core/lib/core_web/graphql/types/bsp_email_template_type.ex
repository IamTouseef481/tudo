defmodule CoreWeb.GraphQL.Types.BspEmailTemplate do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :bsp_email_template_type do
    field :id, non_null(:id)
    field :branch_id, :integer
    field :application_id, :string
    field :action, :string
    field :name, :string
    field :send_in_blue_email_template_id, :integer
    field :send_in_blue_notification_template_id, :integer
  end

  object :application_type do
    field :id, non_null(:id)
    field :name, :string
  end

  input_object :bsp_email_template_input_type do
    field :branch_id, non_null(:integer)
    field :application_id, non_null(:string)
    field :action, non_null(:string)
    field :name, :string
    field :send_in_blue_email_template_id, :integer
    field :send_in_blue_notification_template_id, :integer
  end

  input_object :bsp_email_template_update_type do
    field :id, non_null(:integer)
    field :send_in_blue_email_template_id, :integer
    field :send_in_blue_notification_template_id, :integer
  end

  input_object :bsp_email_template_delete_type do
    field :id, non_null(:integer)
  end

  input_object :email_templates_get_by_type do
    field :branch_id, non_null(:integer)
    field :action, :string
    field :send_in_blue_email_template_id, :integer
    field :send_in_blue_notification_template_id, :integer
    field :application_id, :string
  end
end
