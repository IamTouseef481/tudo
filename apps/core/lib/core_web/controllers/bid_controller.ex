defmodule CoreWeb.Controllers.BidController do
  @moduledoc false

  use CoreWeb, :controller

  alias CoreWeb.Helpers.BidHelper
  alias Core.{Bids, BSP, Jobs, Services}
  alias Core.Jobs.JobNotificationHandler

  @default_error ["unexpected error occurred!"]

  def create_bidding_job(input) do
    with {:ok, _data} <- get_country_service(input),
         {:ok, _data} <- get_service_type(input),
         {:ok, _data} <- get_job_category(input),
         {:ok, _, all} <- BidHelper.create_bidding_job(input),
         %{bidding_job: bidding_job, employees: employees} <- all,
         _ <- send_bidding_job_notification(employees) do
      {:ok, bidding_job}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["Something went wrong, unable to create the Bidding job , try again"],
          __ENV__.line
        )
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't create the Bidding job"],
        __ENV__.line
      )
  end

  def update_bidding_job(input) do
    with {:ok, _data} <- get_country_service(input),
         {:ok, _data} <- get_service_type(input),
         {:ok, bidding_job} <- get_bidding_job(input) do
      case Bids.update_bidding_job(bidding_job, input) do
        {:ok, data} -> {:ok, location_dest(data)}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["Something went wrong, unable to update Bidding job"]}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't update Bidding job"],
        __ENV__.line
      )
  end

  # to show bids to bsps(write it)
  def get_bidding_jobs_by(input) do
    bidding_jobs =
      Bids.get_bidding_jobs_by(input)
      |> Enum.map(&location_dest(&1))

    {:ok, bidding_jobs}
  end

  def delete_bidding_job(%{bidding_job_id: id} = input) do
    case Bids.get_bidding_job(id) do
      nil -> {:error, ["bidding job doesn't exist!"]}
      %{} = data -> deletes_bidding_job(data, input)
      _ -> {:error, @default_error}
    end
  end

  def deletes_bidding_job(bidding_job, input) do
    Bids.get_bid_proposals_by(input) |> Enum.each(&Bids.delete_bid_proposal(&1))

    case Bids.delete_bidding_job(bidding_job) do
      {:ok, data} -> {:ok, location_dest(data)}
      {:error, _error} -> {:error, ["Something went wrong, can't delete Bidding job"]}
      _ -> {:error, @default_error}
    end
  end

  def create_bid_proposal(input) do
    with {:ok, _last, all} <- BidHelper.create_bid_proposal(input),
         %{chat_data: data, bid_proposal_quote: quotes} <- all do
      {:ok, Map.put(data, :quotes, quotes)}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["Something went wrong, unable to create Bid proposal"]}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't create Bid proposal"],
        __ENV__.line
      )
  end

  def update_bid_proposal(input) do
    with {:ok, _data} <- get_country_service(input),
         {:ok, _data} <- get_service_type(input),
         {:ok, bid} <- get_bid_proposal(input) do
      case Bids.update_bid_proposal(bid, input) do
        {:ok, data} -> {:ok, preload_branch(data)}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["unable to update bid proposal"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["can't update bid proposal"], __ENV__.line)
  end

  def delete_bid_proposal(%{bid_id: id}) do
    case Bids.get_bid_proposal(id) do
      nil -> {:error, ["Bid proposal doesn't exist!"]}
      %{} = data -> Bids.delete_bid_proposal(data)
      _ -> {:error, @default_error}
    end
  end

  defp send_bidding_job_notification(%{employees: employees, bid_title: bid_title, bid_id: bid_id}) do
    Enum.each(employees, fn %{user_id: user_id, branch_id: branch_id} ->
      JobNotificationHandler.sends_notification(
        user_id,
        "bsp",
        %{job_title: bid_title, bid_id: bid_id, branch_id: branch_id},
        "new_bid_request_to_bsp"
      )
    end)

    {:ok, ["valid"]}
  end

  def get_service_type(%{service_type_id: service_type_id}) do
    case Services.get_service_type(service_type_id) do
      nil -> {:error, ["Service type doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, @default_error}
    end
  end

  def get_service_type(params) do
    {:ok, params}
  end

  def get_job_category(%{job_category_id: job_category_id}) do
    case Jobs.get_job_category(job_category_id) do
      nil -> {:error, ["Job Category doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, @default_error}
    end
  end

  def get_job_category(params) do
    {:ok, params}
  end

  def get_country_service(%{country_service_id: service}) do
    case Services.get_country_service(service) do
      nil -> {:error, ["country service doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, @default_error}
    end
  end

  def get_country_service(params) do
    {:ok, params}
  end

  def get_get_bidding_job(%{id: id}) do
    case Bids.get_bidding_job(id) do
      nil -> {:error, ["bidding job doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, @default_error}
    end
  end

  def get_bidding_job(%{id: id}) do
    case Bids.get_bidding_job(id) do
      nil -> {:error, ["bidding job doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, @default_error}
    end
  end

  def get_bidding_job(_), do: {:ok, ["valid"]}

  def get_branch_id(%{branch_id: id}) do
    case Core.BSP.get_branch!(id) do
      nil -> {:error, ["Business Branch doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, @default_error}
    end
  end

  def get_branch_id(_), do: {:ok, ["valid"]}

  def get_bid_proposal(%{id: id}) do
    case Bids.get_bid_proposal(id) do
      nil -> {:error, ["Bid proposal doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, @default_error}
    end
  end

  def get_bid_proposal(_), do: {:ok, ["valid"]}

  def preload_branch(%{branch_id: branch_id} = proposal) do
    case BSP.get_branch!(branch_id) do
      nil -> proposal
      %{} = branch -> Map.merge(proposal, %{branch: branch})
    end
  end

  def preload_branch(proposal), do: proposal
end
