defmodule Core.Schemas.BidProposal do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{BiddingJob, BiddingProposalQuote, Branch}

  schema "bid_proposals" do
    field :cost, :float
    field :is_hourly_cost, :boolean, default: false
    field :remarks, :string
    field :question_answers, :map
    field :rejected_at, :utc_datetime
    belongs_to :branch, Branch
    field :user_id, :integer
    field :chat_group_id, :integer
    belongs_to :bidding_job, BiddingJob
    has_one :bidding_proposal_quote, BiddingProposalQuote

    timestamps()
  end

  @doc false
  def changeset(proposal, attrs) do
    proposal
    |> cast(attrs, [
      :remarks,
      :question_answers,
      :cost,
      :is_hourly_cost,
      :rejected_at,
      :branch_id,
      :bidding_job_id,
      :user_id,
      :chat_group_id
    ])
    |> validate_required([:branch_id, :bidding_job_id, :user_id])
  end
end
