defmodule TudoChat.Repo.Migrations.CreateGroupMembers do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:group_members) do
      add :is_active, :boolean, default: false, null: false
      add :group_id, references(:groups, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:group_members, [:group_id])
    create index(:group_members, [:user_id])
  end
end
