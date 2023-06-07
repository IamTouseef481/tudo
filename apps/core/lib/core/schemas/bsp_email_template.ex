defmodule Core.Schemas.BspEmailTemplate do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "bsp_email_templates" do
    field :send_in_blue_email_template_id, :integer
    field :send_in_blue_notification_template_id, :integer
    field :action, :string
    field :name, :string
    belongs_to :branch, Core.Schemas.Branch
    belongs_to :application, Core.Schemas.Application, type: :string

    timestamps()
  end

  @doc false
  def changeset(bsp_email_template, attrs) do
    bsp_email_template
    |> cast(attrs, [
      :send_in_blue_email_template_id,
      :send_in_blue_notification_template_id,
      :name,
      :action,
      :branch_id,
      :application_id
    ])
    |> validate_required([:branch_id, :action, :application_id])
    |> unique_constraint([:branch_id, :action, :application_id])
  end
end
