defmodule Core.Repo.Migrations.CreateTableSessions do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :token, :string
      add :tenant, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:sessions, [:user_id])
  end
end
