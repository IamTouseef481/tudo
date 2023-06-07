defmodule CoreWeb.GraphQL.Types.EmailTemplateType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :email_template_type do
    field :id, :id
    field :slug, :string
    field :name, :string
    field :message, :string
    field :subject, :string
    field :cc, list_of(:string)
    field :text_body, :string
    field :html_body, :string
    field :is_active, :boolean
    field :send_in_blue_email_template_id, :integer
    field :send_in_blue_notification_template_id, :integer
  end

  input_object :email_template_input_type do
    field :email_templates, list_of(:template_input_type)
  end

  input_object :template_input_type do
    field :slug, non_null(:string)
    field :name, :string
    field :subject, :string
    field :cc, list_of(:string)
    field :text_body, :string
    field :html_body, :string
    field :is_active, :boolean
    field :send_in_blue_email_template_id, :integer
    field :send_in_blue_notification_template_id, :integer
  end

  input_object :delete_email_template_input_type do
    field :id, :integer
  end
end
