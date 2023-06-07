defmodule CoreWeb.Workers.BiddingJobsExpireWorker do
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{Bids, MetaData}
  alias CoreWeb.Helpers.BidHelper

  def perform(id) do
    case Bids.get_bidding_job(id) do
      nil -> {:error, ["Unable to fetch bidding Job"]}
      %{accepted: false} = bid -> update_bid_and_meta(bid)
      bid -> {:ok, bid}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, [exception], __ENV__.line)
  end

  defp update_bid_and_meta(bid) do
    new()
    |> run(:bidding_job, &update_bidding_job/2, &abort/3)
    |> run(:cmr_meta, &update_cmr_meta/2, &abort/3)
    |> run(:bsp_meta, &update_bsp_meta/2, &abort/3)
    |> transaction(Core.Repo, bid)
  end

  defp update_bidding_job(_, bid), do: Bids.update_bidding_job(bid, %{rejected: true})

  defp update_cmr_meta(_, %{cmr_id: cmr_id, id: id}) do
    case MetaData.get_meta_cmr_by(%{type: "dashboard", user_id: cmr_id}) do
      [meta] ->
        count = Bids.get_bid_proposals_count_by(%{bid_id: id})

        {_, updated_meta} =
          get_and_update_in(meta.statistics["bid_request"]["request"], &{&1, &1 - 1})

        {_, updated_meta} =
          get_and_update_in(updated_meta.statistics["bid_request"]["response"], &{&1, &1 - count})

        {_, updated_meta} =
          get_and_update_in(updated_meta.statistics["bid_request"]["count"], &{&1, &1 - 1})

        case MetaData.update_meta_cmr(meta, %{statistics: updated_meta.statistics}) do
          {:ok, data} ->
            Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_cmr_socket: "*")

            CoreWeb.Endpoint.broadcast("meta_cmr:user_id:#{cmr_id}", "meta_cmr", %{
              statistics: data.statistics
            })

            {:ok, data}

          _ ->
            {:ok, ["valid"]}
        end

      _ ->
        {:ok, ""}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["update_cmr_meta expire"], __ENV__.line)
  end

  defp update_bsp_meta(%{bidding_job: bidding_job}, %{cmr_id: _}) do
    updated_bidding_job = Map.merge(bidding_job, %{location: bidding_job.location_dest})

    {:ok, %{employees: employees}} =
      BidHelper.get_employees_for_bids(%{bidding_job: bidding_job}, updated_bidding_job)

    employees_meta =
      Enum.map(employees, fn %{id: id, branch_id: branch_id} ->
        case MetaData.get_dashboard_meta_by_employee_id(id, branch_id, "dashboard") do
          [] ->
            {:error, ["unable to find user meta"]}

          [meta] ->
            {_, updated_meta} =
              get_and_update_in(meta.statistics["proposals"]["requests"], &{&1, &1 - 1})

            {_, updated_meta} =
              get_and_update_in(updated_meta.statistics["proposals"]["proposals"], &{&1, &1 - 1})

            #          {_, updated_meta} = get_and_update_in(updated_meta.statistics["proposals"]["count"], &{&1, &1 - 1})
            case MetaData.update_meta_bsp(meta, %{statistics: updated_meta.statistics}) do
              {:ok, data} ->
                Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_bsp_socket: "*")

                CoreWeb.Endpoint.broadcast("meta_bsp:employee_id:#{id}", "meta_bsp", %{
                  statistics: data.statistics
                })

                {:ok, data}

              _ ->
                {:ok, ["valid"]}
            end

          _ ->
            {:error, ["something went wrong"]}
        end
      end)

    {:ok, employees_meta}
  rescue
    exception ->
      logger(__MODULE__, exception, ["bid proposal not created"], __ENV__.line)
  end
end
