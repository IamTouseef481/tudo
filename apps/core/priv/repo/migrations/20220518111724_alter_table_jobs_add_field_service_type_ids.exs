defmodule Core.Repo.Migrations.AlterTableJobsAddFieldServiceTypeIds do
  @moduledoc false
  use Ecto.Migration

  @table :jobs
  def change do
    alter table(@table) do
      add :branch_service_ids, :map
    end
  end
end
