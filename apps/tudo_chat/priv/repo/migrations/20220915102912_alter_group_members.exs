defmodule TudoChat.Repo.Migrations.AlterGroupMembers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter(table(:group_members)) do
      add :deleted_at, :utc_datetime
    end
  end
end
