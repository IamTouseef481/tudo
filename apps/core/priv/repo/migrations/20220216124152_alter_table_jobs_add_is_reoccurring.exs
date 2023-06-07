defmodule Core.Repo.Migrations.AlterTableJobsAddIsReoccurring do
  @moduledoc false
  use Ecto.Migration

  @table :jobs
  def change do
    alter table(@table) do
      add :is_reoccurring, :boolean, null: false, default: false
    end
  end
end
