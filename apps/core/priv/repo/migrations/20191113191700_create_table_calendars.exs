defmodule Core.Repo.Migrations.CreateTableCalendars do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:calendars) do
      add :schedule, :map
      add :user_id, references(:users, on_delete: :delete_all)
      add :employee_id, references(:employees, on_delete: :delete_all)

      timestamps()
    end

    create index(:calendars, [:user_id, :employee_id])
  end
end
