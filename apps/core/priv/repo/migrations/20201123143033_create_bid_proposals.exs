defmodule Core.Repo.Migrations.CreateBidProposals do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:bid_proposals) do
      add :remarks, :text
      add :question_answers, :map
      add :cost, :float
      add :is_hourly_cost, :boolean, default: false, null: false
      add :rejected_at, :utc_datetime
      add :branch_id, :integer
      add :chat_group_id, :integer
      add :bidding_job_id, references(:bidding_jobs, on_delete: :nothing)
      add :user_id, :integer

      timestamps()
    end

    create index(:bid_proposals, [:bidding_job_id])
  end
end
