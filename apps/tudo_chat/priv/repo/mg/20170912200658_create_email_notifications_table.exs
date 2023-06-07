defmodule Stitch.Repo.Migrations.CreateEmailNotificationsTable do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:email_notifications) do
      add :message_id, references(:messages, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps(updated_at: false)
    end

    create index(:email_notifications, :user_id)
    create unique_index(:email_notifications, [:user_id, :message_id])
  end
end
