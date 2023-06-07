defmodule Stitch.Repo.Migrations.AddNotificationPreferenceToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :desktop_notification_preference, :string, default: "everything", null: false
      add :mobile_notification_preference, :string, default: "everything", null: false
      add :email_notification_preference, :string, default: "daily", null: false
    end
  end
end
