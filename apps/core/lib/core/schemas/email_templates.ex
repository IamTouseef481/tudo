defmodule Core.Schemas.EmailTemplates do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "email_templates" do
    field :slug, :string
    field :name, :string
    field :subject, :string
    field :cc, {:array, :string}
    field :text_body, :string
    field :html_body, :string
    field :send_in_blue_email_template_id, :integer
    field :send_in_blue_notification_template_id, :integer
    field :is_active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(email_templates, attrs) do
    email_templates
    |> cast(attrs, [
      :slug,
      :cc,
      :subject,
      :text_body,
      :html_body,
      :is_active,
      :send_in_blue_email_template_id,
      :send_in_blue_notification_template_id,
      :name
    ])
    |> validate_required([:slug, :is_active])
    |> unique_constraint([:send_in_blue_email_template_id, :slug])
    |> unique_constraint([:send_in_blue_notification_template_id, :slug])
  end

  def update_changeset(email_templates, attrs) do
    email_templates
    |> cast(attrs, [
      :send_in_blue_email_template_id,
      :send_in_blue_notification_template_id
    ])
    |> validate_required([:slug, :is_active])
    |> unique_constraint([:send_in_blue_email_template_id, :slug])
    |> unique_constraint([:send_in_blue_notification_template_id, :slug])
  end
end
