defmodule Core.Schemas.AdminNotificationSetting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "admin_notification_settings" do
    field :bsp_email, :boolean, default: true
    field :bsp_notification, :boolean, default: true
    field :cmr_email, :boolean, default: true
    field :cmr_notification, :boolean, default: true
    field :event, :string
    field :slug, :string
    belongs_to :category, Core.Schemas.EmailCategory, type: :string

    timestamps()
  end

  @doc false
  def changeset(admin_notification_setting, attrs) do
    admin_notification_setting
    |> cast(attrs, [
      :event,
      :slug,
      :cmr_email,
      :bsp_email,
      :cmr_notification,
      :bsp_notification,
      :category_id
    ])
    |> validate_required([:slug, :cmr_email, :bsp_email, :cmr_notification, :bsp_notification])
    |> unique_constraint(:slug)
  end
end
