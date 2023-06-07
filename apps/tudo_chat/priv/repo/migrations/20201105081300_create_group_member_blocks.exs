defmodule TudoChat.Repo.Migrations.CreateGroupMemberBlocks do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:group_member_blocks) do
      add :user_from_id, :integer
      add :user_to_id, :integer
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps()
    end

    create index(:group_member_blocks, [:group_id])
  end
end
