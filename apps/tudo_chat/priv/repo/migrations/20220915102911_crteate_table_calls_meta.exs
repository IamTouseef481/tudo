defmodule TudoChat.Repo.Migrations.CreateTableCallsMeta do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:calls_meta) do
      add :participant_id, :integer
      add :call_start_time, :utc_datetime
      add :call_end_time, :utc_datetime
      add :status, :string
      add :call_duration, :time
      add :admin, :boolean
      add :call_id, references(:calls, on_delete: :nothing)

      timestamps()
    end
  end
end
