defmodule Core.Repo.Migrations.AlterTableJobsAddWillPickAt do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :will_pick_at, :utc_datetime
    end
  end
end
