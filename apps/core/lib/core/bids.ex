defmodule Core.Bids do
  @moduledoc """
  The Bids context.
  """

  import Ecto.Query
  alias Core.Repo

  alias Core.Schemas.{BiddingJob, BidProposal, User, BiddingProposalQuote}

  @doc """
  Returns the list of bidding_jobs.

  ## Examples

      iex> list_bidding_jobs()
      [%BiddingJob{}, ...]

  """
  def list_bidding_jobs do
    Repo.all(BiddingJob)
  end

  @doc """
  Gets a single bidding_job.

  Raises `Ecto.NoResultsError` if the bidding_job does not exist.

  ## Examples

      iex> get_bidding_job!(123)
      %BiddingJob{}

      iex> get_bidding_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bidding_job!(id), do: Repo.get!(BiddingJob, id)
  def get_bidding_job(id), do: Repo.get(BiddingJob, id)

  def get_bidding_jobs_by(%{cmr_id: cmr_id}) do
    from(b in BiddingJob,
      join: cmr in User,
      on: cmr.id == b.cmr_id,
      where: b.cmr_id == ^cmr_id and not b.accepted,
      select: %{
        cmr: cmr,
        bidding_job: b
      },
      preload: [proposals: [:branch, :bidding_proposal_quote]]
    )
    |> Repo.all()
  end

  #  def get_bidding_jobs_by(%{country_service_id: id, branch_id: branch_id})  do
  #    from(b in BiddingJob,
  #      left_join: p in BidProposal, on: p.bidding_job_id == b.id,
  ##      where: b.country_service_id == ^id and not b.accepted,
  #      group_by: [p.branch_id, b.id],
  ##      having: count(p.id) <= 0,
  #      having: fragment("SELECT COUNT(*) FROM BID_PROPOSALS p
  #      LEFT JOIN bidding_jobs bj on p.bidding_job_id = bj.id WHERE p.branch_id = ?", ^branch_id) <= 0,
  #
  ##      having: fragment("SELECT COUNT(*) FROM BID_PROPOSALS p
  ##         LEFT JOIN bidding_jobs bj on p.bidding_job_id = bj.id WHERE p.branch_id = ? AND
  ##          bj.country_service_id = ? and not bj.accepted", ^branch_id, ^id) <= 0,
  #      preload: [proposals: :branch]
  #    )
  #    |> Repo.all()
  #  end

  def get_bidding_jobs_by(%{
        country_service_ids: ids,
        user_id: user_id,
        branch_coordinates: %{coordinates: {long, lat}}
      }) do
    from(bj in BiddingJob,
      where:
        fragment(
          "SELECT ST_DistanceSphere(
            ?,
            ST_SetSRID(ST_MakePoint(?, ?),4326)
            )/1000 <= ?",
          bj.location_dest,
          ^long,
          ^lat,
          ^150
        ),
      where: bj.country_service_id in ^ids and not bj.accepted and bj.cmr_id != ^user_id,
      preload: [proposals: :branch]
    )
    |> Repo.all()
  end

  def get_bidding_jobs_by(%{
        country_service_id: id,
        user_id: user_id,
        branch_coordinates: %{coordinates: {long, lat}}
      }) do
    from(bj in BiddingJob,
      where:
        fragment(
          "SELECT ST_DistanceSphere(
            ?,
            ST_SetSRID(ST_MakePoint(?, ?),4326)
            )/1000 <= ?",
          bj.location_dest,
          ^long,
          ^lat,
          ^150
        ),
      where: bj.country_service_id == ^id and not bj.accepted and bj.cmr_id != ^user_id,
      preload: [proposals: :branch]
    )
    |> Repo.all()
  end

  def get_bidding_jobs_count(%{
        country_service_ids: ids,
        user_id: user_id,
        branch_coordinates: %{coordinates: {long, lat}}
      }) do
    from(bj in BiddingJob,
      where:
        fragment(
          "SELECT ST_DistanceSphere(
        ?,
        ST_SetSRID(ST_MakePoint(?, ?),4326)
        )/1000 <= ?",
          bj.location_dest,
          ^long,
          ^lat,
          ^150
        ),
      where: bj.country_service_id in ^ids and not bj.accepted and bj.cmr_id != ^user_id,
      select: count(bj.id)
    )
    |> Repo.one()
  end

  @doc """
  Creates a bidding_job.

  ## Examples

      iex> create_bidding_job(%{field: value})
      {:ok, %BiddingJob{}}

      iex> create_bidding_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bidding_job(attrs \\ %{}) do
    %BiddingJob{}
    |> BiddingJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bidding_job.

  ## Examples

      iex> update_bidding_job(bidding_job, %{field: new_value})
      {:ok, %BiddingJob{}}

      iex> update_bidding_job(bidding_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bidding_job(%BiddingJob{} = bidding_job, attrs) do
    bidding_job
    |> BiddingJob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bidding_job.

  ## Examples

      iex> delete_bidding_job(bidding_job)
      {:ok, %BiddingJob{}}

      iex> delete_bidding_job(bidding_job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bidding_job(%BiddingJob{} = bidding_job) do
    Repo.delete(bidding_job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bidding_job changes.

  ## Examples

      iex> change_bidding_job(bidding_job)
      %Ecto.Changeset{source: %BiddingJob{}}

  """
  def change_bidding_job(%BiddingJob{} = bidding_job) do
    BiddingJob.changeset(bidding_job, %{})
  end

  @doc """
  Returns the list of bid_proposals.

  ## Examples

      iex> list_bid_proposals()
      [%BidProposal{}, ...]

  """
  def list_bid_proposals do
    Repo.all(BidProposal)
  end

  @doc """
  Gets a single proposal.

  Raises `Ecto.NoResultsError` if the Proposal does not exist.

  ## Examples

      iex> get_proposal!(123)
      %BidProposal{}

      iex> get_proposal!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bid_proposal!(id), do: Repo.get!(BidProposal, id)
  def get_bid_proposal(id), do: Repo.get(BidProposal, id)

  def get_bid_proposals_by_bid_and_branch(bid_id, branch_id) do
    from(p in BidProposal,
      where: p.bidding_job_id == ^bid_id and p.branch_id == ^branch_id,
      select: count(p.id)
    )
    |> Repo.one()
  end

  def get_bid_proposals_by(%{branch_id: branch_id}) do
    from(p in BidProposal, where: p.branch_id == ^branch_id and is_nil(p.rejected_at))
    |> Repo.all()
  end

  def get_bid_proposals_by(%{bid_id: bid_id}) do
    from(p in BidProposal, where: p.bidding_job_id == ^bid_id)
    |> Repo.all()
  end

  def get_bid_proposals_count_by(%{bid_id: bid_id}) do
    from(p in BidProposal,
      where: p.bidding_job_id == ^bid_id,
      select: count(p.id)
    )
    |> Repo.one()
  end

  @doc """
  Creates a BidProposal.

  ## Examples

      iex> create_proposal(%{field: value})
      {:ok, %BidProposal{}}

      iex> create_proposal(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bid_proposal(attrs \\ %{}) do
    %BidProposal{}
    |> BidProposal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a proposal.

  ## Examples

      iex> update_proposal(proposal, %{field: new_value})
      {:ok, %BidProposal{}}

      iex> update_proposal(proposal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bid_proposal(%BidProposal{} = bid_proposal, attrs) do
    bid_proposal
    |> BidProposal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a proposal.

  ## Examples

      iex> delete_proposal(proposal)
      {:ok, %BidProposal{}}

      iex> delete_proposal(proposal)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bid_proposal(%BidProposal{} = bid_proposal) do
    Repo.delete(bid_proposal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking proposal changes.

  ## Examples

      iex> change_proposal(proposal)
      %Ecto.Changeset{source: %BidProposal{}}

  """
  def change_bid_proposal(%BidProposal{} = bid_proposal) do
    BidProposal.changeset(bid_proposal, %{})
  end

  def create_bid_proposal_quotes(attrs \\ %{}) do
    %BiddingProposalQuote{}
    |> BiddingProposalQuote.changeset(attrs)
    |> Repo.insert()
  end

  def get_bidding_proposal_quotes!(id), do: Repo.get!(BiddingProposalQuote, id)
  def get_bidding_proposal_quotes(id), do: Repo.get(BiddingProposalQuote, id)

  def get_bidding_proposal_quote_by(bidding_proposal_id),
    do: Repo.get_by(BiddingProposalQuote, bid_proposal_id: bidding_proposal_id)
end
