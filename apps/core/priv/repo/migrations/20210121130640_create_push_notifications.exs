defmodule Core.Repo.Migrations.CreatePushNotifications do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:push_notifications) do
      add :title, :string
      add :description, :text
      add :read, :boolean, default: false, null: false
      add :pushed_at, :utc_datetime
      add :acl_role_id, :string
      add :branch_id, references(:branches, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:push_notifications, [:user_id, :branch_id])
  end
end
