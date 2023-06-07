defmodule Core.Repo.Migrations.CreateTableShiftSchedules do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:shift_schedules, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :start_time, :time
      add :end_time, :time

      timestamps()
    end
  end
end
