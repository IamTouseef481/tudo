defmodule Core.Repo.Migrations.AlterTableBiddingJobsAddJobCategory do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:bidding_jobs) do
      add :job_category_id, references(:job_categories, type: :varchar, on_delete: :nothing)
    end

    create index(:bidding_jobs, [:job_category_id])
  end
end
