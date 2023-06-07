defmodule TudoChat.Repo.Migrations.CreateCalendars do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:calendars) do
      add :calendar_title, :string
      add :calendar_desc, :string
      add :all_day, :boolean, default: false, null: false
      add :start_date, :utc_datetime
      add :duration, :utc_datetime
      add :recurring, :string
      add :recurring_interval, :string
      add :number_of_occurances, :integer
      add :end_date, :utc_datetime
      add :reminders, :map
      add :alarm_sound, :string
      add :snooz, :boolean, default: false, null: false
      add :show_us, :string
      add :group_id, references(:groups, on_delete: :nothing)
      add :created_by_id, references(:users, on_delete: :nothing)
      add :last_updated_by_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:calendars, [:group_id])
    create index(:calendars, [:created_by_id])
    create index(:calendars, [:last_updated_by_id])
  end
end
