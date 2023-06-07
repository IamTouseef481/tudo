defmodule CoreWeb.GraphQL.Resolvers.BidResolver do
  @moduledoc false

  import CoreWeb.Utils.CommonFunctions

  alias Core.{Bids, BSP, Services}
  alias CoreWeb.Controllers.{BidController}

  def create_bidding_job(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input =
      if Map.has_key?(input, :dynamic_fields) do
        Map.merge(input, %{dynamic_fields: string_to_map(input.dynamic_fields)})
      else
        input
      end

    input =
      case input do
        %{location_dest: location} ->
          Map.merge(input, %{location_dest: location_struct(location)})

        _ ->
          input
      end

    input = Map.merge(input, %{cmr_id: current_user.id, posted_at: DateTime.utc_now()})

    case BidController.create_bidding_job(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_bidding_job(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    input =
      if Map.has_key?(input, :dynamic_fields) do
        Map.merge(input, %{dynamic_fields: string_to_map(input.dynamic_fields)})
      else
        input
      end

    input =
      case input do
        %{location_dest: %{lat: lat, long: long}} ->
          Map.merge(input, %{location_dest: %Geo.Point{coordinates: {long, lat}, srid: 4326}})

        _ ->
          input
      end

    case CoreWeb.Controllers.BidController.update_bidding_job(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_bidding_jobs_by(_, %{input: %{cmr_id: cmr_id}}, %{
        context: %{current_user: current_user}
      }) do
    if cmr_id == current_user.id do
      bidding_jobs =
        Bids.get_bidding_jobs_by(%{cmr_id: cmr_id})
        |> Enum.map(fn %{bidding_job: bidding_job, cmr: cmr} ->
          bidding_job = location_dest(bidding_job)

          proposals =
            Enum.map(
              bidding_job.proposals,
              &Map.merge(&1, %{branch: add_geo(&1.branch), quotes: &1.bidding_proposal_quote})
            )

          Map.merge(bidding_job, %{proposals: proposals, cmr: cmr})
        end)

      {:ok, bidding_jobs}
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  #  results are filtered here in Enum.reduce
  def get_bidding_jobs_by(_, %{input: %{country_service_id: _, branch_id: branch_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    case BSP.get_branch!(branch_id) do
      %{} = branch ->
        {:ok,
         Bids.get_bidding_jobs_by(
           Map.merge(input, %{user_id: current_user.id, branch_coordinates: branch.location})
         )
         |> Enum.reduce([], fn
           %{id: _, proposals: proposals} = bidding_job, acc ->
             branch_ids = Enum.map(proposals, & &1.branch_id)

             if false == branch_id in branch_ids do
               bidding_job = location_dest(bidding_job)

               proposals =
                 Enum.map(
                   bidding_job.proposals,
                   &Map.merge(&1, %{
                     branch: add_geo(&1.branch),
                     quotes: &1.bidding_proposal_quote
                   })
                 )

               acc ++ [%{bidding_job | proposals: proposals}]
             else
               acc
             end
         end)}

      _ ->
        {:error, ["Error While Getting Branch"]}
    end
  end

  #  trying to get proper results from query
  #  def get_bidding_jobs_by(_, %{input: %{country_service_id: _} = input}, %{context: %{current_user: _current_user}}) do
  #    bidding_jobs = Bids.get_bidding_jobs_by(input)
  #                   |> Enum.map(fn bidding_job ->
  #      bidding_job = location_dest(bidding_job)
  #      proposals = Enum.map(bidding_job.proposals, &Map.merge(&1, %{branch: add_geo(&1.branch)}))
  #      %{bidding_job | proposals: proposals}
  #    end)
  #
  #    {:ok, bidding_jobs}
  #  end

  def get_bidding_jobs_by(_, %{input: %{branch_id: branch_id}}, %{
        context: %{current_user: current_user}
      }) do
    cs_ids = Services.get_country_services_by_branch_id(branch_id)

    case BSP.get_branch!(branch_id) do
      %{} = branch ->
        {:ok,
         Bids.get_bidding_jobs_by(%{
           country_service_ids: cs_ids,
           user_id: current_user.id,
           branch_coordinates: branch.location
         })
         |> Enum.reduce([], fn
           %{id: _, proposals: proposals} = bidding_job, acc ->
             branch_ids = Enum.map(proposals, & &1.branch_id)

             if branch_id in branch_ids == false do
               bidding_job = location_dest(bidding_job)

               proposals =
                 Enum.map(
                   bidding_job.proposals,
                   &Map.merge(&1, %{
                     branch: add_geo(&1.branch),
                     quotes: &1.bidding_proposal_quote
                   })
                 )

               acc ++ [%{bidding_job | proposals: proposals}]
             else
               acc
             end
         end)}

      _ ->
        {:error, ["Error While Getting Branch"]}
    end
  end

  def get_bidding_jobs_by(_, %{input: _}, %{context: %{current_user: _current_user}}) do
    {:error, ["params are not correct"]}
  end

  def delete_bidding_job(_, %{input: input}, _) do
    case BidController.delete_bidding_job(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_bid_proposal(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input =
      case input do
        %{question_answers: question_answers} ->
          Map.merge(input, %{question_answers: string_to_map(question_answers)})

        _ ->
          input
      end

    input = Map.merge(input, %{user_id: current_user.id})

    case BidController.create_bid_proposal(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_bid_proposal(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    input =
      case input do
        %{question_answers: question_answers} ->
          Map.merge(input, %{question_answers: string_to_map(question_answers)})

        _ ->
          input
      end

    case CoreWeb.Controllers.BidController.update_bid_proposal(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_bid_proposals_by(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    proposals =
      Bids.get_bid_proposals_by(input)
      |> Enum.map(&BidController.preload_branch(&1))

    {:ok, proposals}
  end

  def delete_bid_proposal(_, %{input: input}, _) do
    case BidController.delete_bid_proposal(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
