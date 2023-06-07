defmodule Core.Repo.Migrations.CreateTableUserSchedules do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:user_schedules) do
      add :schedule, :map
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_schedules, [:user_id])
  end
end
