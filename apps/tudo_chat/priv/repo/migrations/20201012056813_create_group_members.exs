defmodule TudoChat.Repo.Migrations.CreateGroupMembers do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:group_members) do
      add :is_active, :boolean, default: true, null: false
      add :group_id, references(:groups, on_delete: :delete_all)
      add :user_id, :integer
      add :role_id, references(:group_member_roles, type: :varchar, on_delete: :nothing)
      #      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:group_members, [:group_id])
    create index(:group_members, [:role_id])
    #    create index(:group_members, [:user_id])
  end
end
