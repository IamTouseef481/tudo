defmodule TudoChat.Repo.Migrations.AlterTableGroupsAddFieldLink do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :link, :string
    end
  end
end
