defmodule Core.Repo.Migrations.AlterTableJobsAddPickedAt do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :picked_at, :utc_datetime
    end
  end
end
