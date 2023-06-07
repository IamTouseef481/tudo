defmodule Core.Repo.Migrations.CreateAdminNotificationSettings do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:admin_notification_settings) do
      add :event, :string
      add :slug, :string
      add :cmr_email, :boolean, default: true, null: false
      add :bsp_email, :boolean, default: true, null: false
      add :cmr_notification, :boolean, default: true, null: false
      add :bsp_notification, :boolean, default: true, null: false
      add :category_id, references(:email_categories, on_delete: :nothing, type: :varchar)

      timestamps()
    end

    create index(:admin_notification_settings, [:category_id])
    create unique_index(:admin_notification_settings, :slug)
  end
end
