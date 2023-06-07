defmodule CoreWeb.Helpers.BidHelper do
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{Bids, BSP, Employees, MetaData, Payments, PaypalPayments, Services}
  alias Core.Jobs.SettingsPicker
  alias Core.PaypalPayments.SubscriptionHandler, as: Common
  alias CoreWeb.Controllers.JobController
  alias CoreWeb.GraphQL.Resolvers.LeadResolver
  alias CoreWeb.Utils.CommonFunctions
  alias CoreWeb.GraphQL.Resolvers.InvoiceResolver

  #
  # Main actions
  #

  def create_bidding_job(params) do
    new()
    |> run(:bidding_job, &create_bidding_job/2, &abort/3)
    |> run(:lead, &create_lead/2, &abort/3)
    |> run(:update_cmr_meta, &update_cmr_meta/2, &abort/3)
    |> run(:employees, &get_employees_for_bids/2, &abort/3)
    |> run(:update_bsp_meta, &update_bsp_meta_for_bidding_jobs/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_bid_proposal(params) do
    new()
    |> run(:get_bid, &get_bid/2, &abort/3)
    |> run(:get_branch, &get_branch_id/2, &abort/3)
    |> run(:updated_params, &make_bid_proposal_cost/2, &abort/3)
    |> run(:subscription, &verify_subscription_usage/2, &abort/3)
    |> run(:bid_proposal, &create_bid_proposal/2, &abort/3)
    |> run(:update_bsp_meta, &update_bsp_meta/2, &abort/3)
    |> run(:update_cmr_meta, &update_cmr_meta_for_proposals/2, &abort/3)
    |> run(:chat_data, &create_chat_group/2, &abort/3)
    |> run(:bid_proposal_quote, &create_bid_proposal_quote/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------

  #
  # Handle update subscription_usage
  #

  defp create_bidding_job(_, input) do
    case Bids.create_bidding_job(input) do
      {:ok, data} ->
        Exq.enqueue_at(
          Exq,
          "default",
          Timex.shift(DateTime.utc_now(), months: 2),
          "CoreWeb.Workers.BiddingJobsExpireWorker",
          [data.id]
        )

        {:ok, CommonFunctions.location_dest(data)}

      {:error, changeset} ->
        {:error, changeset}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["bid job not created"], __ENV__.line)
  end

  defp create_lead(_, %{location_dest: location, cmr_id: cmr_id} = input) do
    input = Map.merge(input, %{location: location, user_id: cmr_id})

    case LeadResolver.create_lead(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["bid job not created"], __ENV__.line)
  end

  defp update_cmr_meta(_, %{cmr_id: cmr_id}) do
    case MetaData.get_dashboard_meta_by_user_id(cmr_id, "dashboard") do
      [] ->
        {:error, ["unable to find user meta"]}

      [meta] ->
        {_, updated_meta} =
          get_and_update_in(meta.statistics["bid_request"]["request"], &{&1, &1 + 1})

        {_, updated_meta} =
          get_and_update_in(updated_meta.statistics["bid_request"]["count"], &{&1, &1 + 1})

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
        {:error, ["something went wrong"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["bid job not created"], __ENV__.line)
  end

  defp update_cmr_meta_for_proposals(%{get_bid: %{cmr_id: cmr_id}}, _) do
    case MetaData.get_dashboard_meta_by_user_id(cmr_id, "dashboard") do
      [] ->
        {:error, ["unable to find user meta"]}

      [meta] ->
        {_, updated_meta} =
          get_and_update_in(meta.statistics["bid_request"]["response"], &{&1, &1 + 1})

        #        {_, updated_meta} = get_and_update_in(updated_meta.statistics["bid_request"]["request"], &{&1, &1 - 1})
        #        {_, updated_meta} = get_and_update_in(updated_meta.statistics["bid_request"]["count"], &{&1, &1 - 1})
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
        {:error, ["something went wrong"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["bid job not created"], __ENV__.line)
  end

  defp update_bsp_meta_for_bidding_jobs(%{employees: %{employees: employees}}, _) do
    meta =
      Enum.map(employees, fn %{id: id, branch_id: branch_id} ->
        case MetaData.get_dashboard_meta_by_employee_id(id, branch_id, "dashboard") do
          [] ->
            {:ok, ["valid"]}

          [data] ->
            {_, data} = get_and_update_in(data.statistics["proposals"]["count"], &{&1, &1 + 1})

            {_, %{statistics: updated_statistics}} =
              get_and_update_in(data.statistics["proposals"]["requests"], &{&1, &1 + 1})

            case MetaData.update_meta_bsp(data, %{statistics: updated_statistics}) do
              {:ok, data} ->
                Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_bsp_socket: "*")

                CoreWeb.Endpoint.broadcast("meta_bsp:employee_id:#{id}", "meta_bsp", %{
                  statistics: updated_statistics
                })

                data

              _ ->
                {:ok, ["valid"]}
            end
        end
      end)

    {:ok, meta}
  end

  def get_employees_for_bids(
        %{bidding_job: %{id: bid_id}},
        %{title: bid_title, location_dest: location, cmr_id: user_id} = input
      ) do
    input = Map.merge(input, %{location: location, user_id: user_id, bid_id: bid_id})

    branches =
      BSP.get_branches_for_prospects(input, :bid)
      |> filter_branches_by_distance(input)

    employees =
      Enum.reduce(branches, [], fn %{branch_id: branch_id}, acc ->
        case Employees.get_owner_by_branch_id(branch_id) do
          %{id: id, user_id: user_id} -> [%{id: id, user_id: user_id, branch_id: branch_id} | acc]
          _ -> acc
        end
      end)

    {:ok, %{employees: employees, bid_title: bid_title, bid_id: bid_id}}
  rescue
    exception ->
      logger(__MODULE__, exception, ["bid notification not sent"], __ENV__.line)
  end

  def filter_branches_by_distance(items, %{location: %{coordinates: coordinates}}) do
    Enum.filter(items, fn
      %{location: %{coordinates: branch_coordinates}} ->
        calculate_distance(branch_coordinates, coordinates)

      %{location_dest: %{coordinates: bid_coordinates}} ->
        calculate_distance(coordinates, bid_coordinates)
    end)
  end

  defp calculate_distance(branch_coordinates, cmr_coordinates) do
    if CommonFunctions.calculate_distance_between_two_coordinates(
         branch_coordinates,
         cmr_coordinates
       ) <= 150 do
      true
    else
      false
    end
  end

  defp verify_subscription_usage(_, %{branch_id: branch_id}) do
    case BSP.get_branch!(branch_id) do
      nil ->
        {:error, ["branch doesn't exist"]}

      %{business_id: business_id} ->
        case PaypalPayments.get_paypal_subscription_by_business(business_id) do
          [] ->
            {:error, ["Bid Proposal can't Created. Please Upgrade Your Plan"]}

          [%{bid_proposal: bid_proposal, annual: annual} = subscription | _] ->
            case Common.updated_subscription_usage(subscription, annual, %{
                   bid_proposal: bid_proposal
                 }) do
              {:ok, data} -> {:ok, data}
              {:error, _} -> verify_additional_purchased_proposals(branch_id)
            end
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to verify_subscription_usage"], __ENV__.line)
  end

  defp verify_additional_purchased_proposals(branch_id) do
    case Payments.get_available_subscription_feature_by_branch(branch_id) do
      [] ->
        {:error, ["proposal can't Created. Please Upgrade Your Plan"]}

      [proposal | _] ->
        Payments.update_available_subscription_feature(proposal, %{used_at: DateTime.utc_now()})
    end
  end

  def get_bid(_, %{bidding_job_id: id}) do
    case Bids.get_bidding_job(id) do
      nil -> {:error, ["bidding job doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def get_bid(_, _), do: {:ok, ["valid"]}

  def get_branch_id(_, %{branch_id: id}) do
    case JobController.get_branch(%{branch_id: id}) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def get_branch_id(_, _), do: {:ok, ["valid"]}

  def make_bid_proposal_cost(_, %{cost: _cost} = params) do
    {:ok, params}
  end

  def make_bid_proposal_cost(_, %{bidding_job_id: bidding_job_id, branch_id: branch_id} = params) do
    case Bids.get_bidding_job(bidding_job_id) do
      nil ->
        {:error, ["bidding job doesn't exist!"]}

      %{country_service_id: cs_id, service_type_id: type, expected_work_duration: ewd} ->
        case Services.get_branch_services_by(%{
               country_service_id: cs_id,
               branch_id: branch_id,
               service_type_id: type
             }) do
          [] ->
            {:error, ["branch service does not exist"]}

          [%{id: bs_id} | _] ->
            making_bid_proposal_cost(
              %{
                country_service_id: cs_id,
                branch_id: branch_id,
                service_type_id: type,
                expected_work_duration: ewd,
                branch_service_id: bs_id
              },
              params
            )
        end
    end
  end

  defp making_bid_proposal_cost(params_for_cost, params) do
    case SettingsPicker.make_job_cost(params_for_cost) do
      {:error, error} -> {:error, error}
      {:ok, %{cost: cost}} -> {:ok, Map.merge(params, %{cost: cost})}
    end
  end

  defp create_bid_proposal(%{updated_params: params}, _input) do
    case Bids.create_bid_proposal(params) do
      {:ok, data} -> {:ok, preload_branch(data)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp update_bsp_meta(_, %{user_id: user_id, branch_id: branch_id}) do
    case Employees.get_owner_by_branch_id(branch_id) do
      nil ->
        {:error, ["unable to get branch owner"]}

      %{id: id} ->
        case MetaData.get_dashboard_meta_by_employee_id(id, branch_id, "dashboard") do
          [] ->
            {:error, ["unable to find user meta"]}

          [meta] ->
            {_, updated_meta} =
              get_and_update_in(meta.statistics["proposals"]["proposals"], &{&1, &1 + 1})

            {_, updated_meta} =
              get_and_update_in(updated_meta.statistics["proposals"]["count"], &{&1, &1 - 1})

            #            {_, updated_meta} = get_and_update_in(updated_meta.statistics["proposals"]["requests"], &{&1, &1 - 1})
            case MetaData.update_meta_bsp(meta, %{statistics: updated_meta.statistics}) do
              {:ok, data} ->
                Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_bsp_socket: "*")

                CoreWeb.Endpoint.broadcast("meta_bsp:user_id:#{user_id}", "meta_bsp", %{
                  statistics: data.statistics
                })

                {:ok, data}

              _ ->
                {:ok, ["valid"]}
            end

          _ ->
            {:error, ["something went wrong"]}
        end

      _ ->
        {:error, ["something went wrong"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["bid job not created"], __ENV__.line)
  end

  def preload_branch(%{branch_id: branch_id} = proposal) do
    case BSP.get_branch!(branch_id) do
      nil -> proposal
      %{} = branch -> Map.merge(proposal, %{branch: branch})
    end
  end

  def preload_branch(proposal), do: proposal

  #  def send_notification_for_create_job(%{job: job}, params) do
  #    JobNotificationHandler.send_notification_for_create_job(job, params)
  #  end

  def create_chat_group(
        %{
          bid_proposal: %{bidding_job_id: _bidding_job_id, id: _proposal_id} = proposal,
          get_bid: %{gallery: gallery}
        },
        _params
      ) do
    params = Map.merge(proposal, %{profile_pic: List.first(gallery)})

    case CoreWeb.Helpers.BidProposalChatHelper.create_chat_group(params) do
      {:ok, _last, %{add_group_id_in_proposal: proposal} = _all} -> {:ok, proposal}
      {:error, :chat_group_not_created} -> {:ok, proposal}
      _ -> {:ok, proposal}
    end
  end

  def create_bid_proposal_quote(
        %{
          get_bid: %{
            country_service_id: country_service_id,
            cmr_id: cmr_id,
            location_dest: location_dest,
            arrive_at: arrive_at
          },
          bid_proposal: %{id: bid_proposal_id, cost: cost}
        },
        %{user_id: user_id, branch_id: branch_id}
      ) do
    %{business_id: business_id} = BSP.get_branch!(branch_id)
    [%{id: employee_id}] = Employees.get_employee_by_branch_id(user_id, branch_id)

    %{country_id: country_id} = Services.get_country_service(country_service_id)

    [bs_id | _] = BSP.get_branch_services(branch_id, [country_service_id]) |> List.flatten()

    {:ok, branch_service_data} = InvoiceResolver.list_services_by_branch_services([bs_id])
    service = InvoiceResolver.filter_required_data(branch_service_data)

    CoreWeb.Controllers.InvoiceController.create_invoice_from(%{
      bid_proposal_id: bid_proposal_id,
      unit_price: cost,
      discountable_price: cost,
      branch_id: branch_id,
      business_id: business_id,
      user_id: user_id,
      cmr_id: cmr_id,
      employee_id: employee_id,
      branch_service_id: bs_id,
      country_id: country_id,
      location_dest: location_dest,
      arrive_at: arrive_at,
      service_id: service.id,
      service_name: service.name
    })
  end
end
