defmodule Core.Jobs.DashboardMetaHandler do
  @moduledoc false
  import CoreWeb.Utils.Errors

  alias Core.{Accounts, Bids, BSP, Employees, MetaData, Services}

  def bsp_meta_socket_processing(data) do
    meta_data = Map.drop(data, [:__meta__, :__struct__])

    employee = Employees.get_employee(data.employee_id)

    employee =
      Map.drop(employee, [
        :manager,
        :employee_setting,
        :branch,
        :employee_status,
        :approved_by,
        :shift_schedule,
        :employee_role,
        :employee_type,
        :pay_rate,
        :user,
        :__meta__,
        :__struct__
      ])

    user = Accounts.get_user!(data.user_id)
    user = Map.drop(user, [:status, :country, :language, :user_address, :__meta__, :__struct__])

    branch = BSP.get_branch!(data.branch_id)

    branch =
      Map.drop(branch, [
        :country,
        :business_type,
        :branch_services,
        :business,
        :city,
        :employees,
        :licence_issuing_authority,
        :__meta__,
        :__struct__
      ])

    {long, lat} = branch.location.coordinates
    _branch_location = %{lat: lat, long: long}
    branch = Map.merge(branch, %{location: %{lat: lat, long: long}})

    Map.merge(meta_data, %{user: user, branch: branch, employee: employee})
  end

  def update_bsp_meta(employee_id, branch_id, type, bidding_proposal_id, rejecting_proposals)
      when false == is_nil(employee_id) do
    if is_nil(bidding_proposal_id) do
      {:ok, update_bsp_meta_for_that_employee(employee_id, branch_id, type)}
    else
      {:ok,
       update_bsp_meta_of_employees(
         employee_id,
         branch_id,
         type,
         bidding_proposal_id,
         rejecting_proposals
       )}
    end
  end

  defp update_bsp_meta_for_that_employee(employee_id, branch_id, type)
       when false == is_nil(employee_id) do
    case MetaData.get_dashboard_meta_by_employee_id(employee_id, branch_id, "dashboard") do
      [] ->
        {:ok, ["valid"]}

      [data] ->
        {_, updated_meta} =
          get_and_update_in(data.statistics["scheduled"]["count"], &{&1, &1 + 1})

        {_, %{statistics: updated_statistics}} =
          get_and_update_in(
            updated_meta.statistics["scheduled"]["#{type}"]["scheduled"],
            &{&1, &1 + 1}
          )

        case MetaData.update_meta_bsp(data, %{statistics: updated_statistics}) do
          {:ok, data} ->
            Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_bsp_socket: "*")

            CoreWeb.Endpoint.broadcast("meta_bsp:employee_id:#{employee_id}", "meta_bsp", %{
              statistics: updated_statistics
            })

            {:ok, data}

          _ ->
            {:ok, ["valid"]}
        end

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        {:ok, ["valid"]}
    end
  end

  defp update_bsp_meta_of_employees(
         employee_id,
         _branch_id,
         type,
         bidding_proposal_id,
         rejecting_proposals
       )
       when false == is_nil(employee_id) do
    [Bids.get_bid_proposal(bidding_proposal_id) | rejecting_proposals]
    |> Enum.reduce([], fn %{branch_id: branch_id}, acc ->
      case Employees.get_owner_by_branch_id(branch_id) do
        %{id: owner_emp_id} ->
          case MetaData.get_dashboard_meta_by_employee_id(owner_emp_id, branch_id, "dashboard") do
            [] ->
              acc

            [data] ->
              #          %{bidding_job_id: id} = Bids.get_bid_proposal(bidding_proposal_id)
              #          count = Bids.get_bid_proposals_count_by(%{bid_id: id})
              {_, updated_meta} =
                get_and_update_in(data.statistics["proposals"]["requests"], &{&1, &1 - 1})

              {_, updated_meta} =
                get_and_update_in(
                  updated_meta.statistics["proposals"]["proposals"],
                  &{&1, &1 - 1}
                )

              #          {_, updated_meta} = get_and_update_in(updated_meta.statistics["proposals"]["count"], &{&1, &1 - 1})

              #        %{user_id: user_id} = Employees.get_employee(employee_id)
              #        count = TudoChat.Groups.get_for_proposals_rejection(proposal_ids, user_id)
              updated_statistics =
                if employee_id == owner_emp_id do
                  {_, updated_meta} =
                    get_and_update_in(
                      updated_meta.statistics["scheduled"]["count"],
                      &{&1, &1 + 1}
                    )

                  {_, %{statistics: updated_statistics}} =
                    get_and_update_in(
                      updated_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                      &{&1, &1 + 1}
                    )

                  updated_statistics
                else
                  %{user_id: user_id} = Employees.get_employee(owner_emp_id)

                  case apply(
                         TudoChat.Messages,
                         :check_if_any_unread_bus_net_message_by_user_and_group_type,
                         [
                           user_id,
                           "bus_net",
                           ["super_admin", "admin"]
                         ]
                       ) do
                    %{} ->
                      {_, %{statistics: updated_statistics}} =
                        get_and_update_in(
                          updated_meta.statistics["bus_net"]["count"],
                          &{&1, &1 - 1}
                        )

                      updated_statistics

                    _ ->
                      updated_meta.statistics
                  end
                end

              case MetaData.update_meta_bsp(data, %{statistics: updated_statistics}) do
                {:ok, data} ->
                  Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_bsp_socket: "*")

                  CoreWeb.Endpoint.broadcast(
                    "meta_bsp:employee_id:#{owner_emp_id}",
                    "meta_bsp",
                    %{statistics: updated_statistics}
                  )

                  [data | acc]

                _ ->
                  acc
              end

            exception ->
              logger(__MODULE__, exception, :info, __ENV__.line)
              acc
          end

        _ ->
          acc
      end
    end)
  end

  def update_cmr_meta(user_id, _branch_id, %{service_type_id: type} = job, proposal_ids) do
    case MetaData.get_dashboard_meta_by_user_id(user_id, "dashboard") do
      [] ->
        {:ok, ["valid"]}

      [data] ->
        data =
          if proposal_ids != [] do
            count = apply(TudoChat.Groups, :get_for_proposals_rejection, [proposal_ids, user_id])

            {_, updated_meta} =
              get_and_update_in(data.statistics["my_net"]["count"], &{&1, &1 - count})

            updated_meta
          else
            data
          end

        updated_statistics =
          cond do
            job.job_cmr_status_id == "confirmed" ->
              data =
                if false == is_nil(job.bidding_proposal_id) do
                  %{bidding_job_id: id} = Bids.get_bid_proposal(job.bidding_proposal_id)
                  count = Bids.get_bid_proposals_count_by(%{bid_id: id})

                  {_, updated_meta} =
                    get_and_update_in(data.statistics["bid_request"]["request"], &{&1, &1 - 1})

                  {_, updated_meta} =
                    get_and_update_in(
                      updated_meta.statistics["bid_request"]["response"],
                      &{&1, &1 - count}
                    )

                  {_, updated_meta} =
                    get_and_update_in(
                      updated_meta.statistics["bid_request"]["count"],
                      &{&1, &1 - 1}
                    )

                  updated_meta
                else
                  data
                end

              {_, data} = get_and_update_in(data.statistics["scheduled"]["count"], &{&1, &1 + 1})

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  data.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            job.job_cmr_status_id == "pending" ->
              {_, data} = get_and_update_in(data.statistics["scheduled"]["count"], &{&1, &1 + 1})

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  data.statistics["scheduled"]["#{type}"]["waiting"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            true ->
              data.statistics
          end

        case MetaData.update_meta_cmr(data, %{statistics: updated_statistics}) do
          {:ok, data} ->
            Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_cmr_socket: "*")

            CoreWeb.Endpoint.broadcast("meta_cmr:user_id:#{user_id}", "meta_cmr", %{
              statistics: updated_statistics
            })

            {:ok, data}

          _ ->
            {:ok, ["valid"]}
        end

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        {:ok, ["valid"]}
    end
  end

  def cmr_meta_socket_processing(data) do
    meta_data = Map.drop(data, [:__meta__, :__struct__])

    user = Accounts.get_user!(data.user_id)
    user = Map.drop(user, [:status, :country, :language, :user_address, :__meta__, :__struct__])
    Map.merge(meta_data, %{user: user})
  end

  def update_bsp_job_meta(previous_job_status, current_job_status, employee_id, type) do
    branch_id = Core.Employees.get_branch_by_employee(employee_id)

    case MetaData.get_dashboard_meta_by_employee_id(employee_id, branch_id, "dashboard") do
      [] ->
        {:ok, ["valid"]}

      [dashboard_meta] ->
        updated_statistics =
          cond do
            current_job_status in ["waiting"] and
                previous_job_status in ["confirmed", "on_board", "on_way", "accept", "reject"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["waiting"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["accept_reject"] and
                previous_job_status in ["confirmed", "accept", "reject"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["RSVP"]["count"], &{&1, &1 + 1})

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["RSVP"]["accept_reject"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["cancelled"] and previous_job_status in ["confirmed"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["cancelled"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["confirmed", "accept", "reject", "on_board", "on_way"] and
                previous_job_status in ["waiting"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 + 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["waiting"],
                  &{&1, &1 - 1}
                )

              updated_statistics

            current_job_status in ["confirmed", "accept", "reject"] and
                previous_job_status in ["accept_reject"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 + 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 + 1}
                )

              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["RSVP"]["count"], &{&1, &1 - 1})

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["RSVP"]["accept_reject"],
                  &{&1, &1 - 1}
                )

              updated_statistics

            current_job_status in ["cancelled"] and previous_job_status in ["waiting"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["waiting"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["cancelled"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["cancelled"] and previous_job_status in ["accept_reject"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["RSVP"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["RSVP"]["accept_reject"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["cancelled"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["cancelled"] and previous_job_status in ["on_way", "on_board"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["cancelled"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["invoiced"] and previous_job_status in ["completed"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["accounter"]["count"], &{&1, &1 + 1})

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["overdues"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["adjust_invoice"] and
                previous_job_status in ["invoiced", "adjusted"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["overdues"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["disputes"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["adjusted"] and previous_job_status in ["adjust_invoice"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["disputes"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["overdues"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["paid"] and
                previous_job_status in ["invoiced", "adjusted", "payment_confirmation_pending"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["accounter"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["overdues"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["closed"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["dispute"] and previous_job_status in ["paid", "closed"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["closed"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["disputes"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["paid", "finalized", "closed"] and
                previous_job_status in ["dispute"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["disputes"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["closed"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["paid"] and
                previous_job_status in ["completed"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["accounter"]["#{type}"]["closed"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            true ->
              dashboard_meta.statistics
          end

        case MetaData.update_meta_bsp(dashboard_meta, %{statistics: updated_statistics}) do
          {:ok, data} ->
            Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_bsp_socket: "*")
            #            meta_data = bsp_meta_socket_processing(data)
            CoreWeb.Endpoint.broadcast("meta_bsp:employee_id:#{employee_id}", "meta_bsp", %{
              statistics: updated_statistics
            })

            {:ok, data}

          {:error, error} ->
            {:error, error}

          _ ->
            {:error, ["Unable to update Service Provider meta"]}
        end

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        {:ok, ["valid"]}
    end
  end

  def update_cmr_job_meta(
        previous_job_status,
        current_job_status,
        user_id,
        type,
        older_job_cmr_status \\ ""
      ) do
    case MetaData.get_dashboard_meta_by_user_id(user_id, "dashboard") do
      [] ->
        {:ok, ["valid"]}

      [dashboard_meta] ->
        updated_statistics =
          cond do
            current_job_status in ["waiting"] and
                previous_job_status in ["confirmed", "accept", "reject"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["waiting"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["accept_reject"] and
                previous_job_status in ["confirmed", "accept", "reject", "on_board"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["RSVP"]["count"], &{&1, &1 + 1})

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["RSVP"]["accept_reject"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["cancelled"] and previous_job_status in ["confirmed"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["cancelled"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["confirmed", "accept", "reject"] and
                previous_job_status in ["waiting"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 + 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["waiting"],
                  &{&1, &1 - 1}
                )

              updated_statistics

            current_job_status in ["confirmed", "accept", "reject", "on_board"] and
                previous_job_status in ["accept_reject"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 + 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 + 1}
                )

              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["RSVP"]["count"], &{&1, &1 - 1})

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["RSVP"]["accept_reject"],
                  &{&1, &1 - 1}
                )

              updated_statistics

            current_job_status in ["cancelled"] and previous_job_status in ["waiting"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["waiting"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["cancelled"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["cancelled"] and previous_job_status in ["accept_reject"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["RSVP"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["RSVP"]["accept_reject"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["cancelled"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["cancelled"] and previous_job_status in ["on_way", "on_board"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["cancelled"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["adjust_invoice"] and previous_job_status in ["invoiced"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["payments"]["count"], &{&1, &1 + 1})

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["disputes"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["adjust_invoice"] and previous_job_status in ["adjusted"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["dues"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["disputes"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["adjusted"] and previous_job_status in ["adjust_invoice"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["disputes"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["dues"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["paid"] and older_job_cmr_status in ["adjusted"] and
                previous_job_status in ["payment_confirmation_pending"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["payments"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["disputes"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["closed"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["paid"] and previous_job_status in ["adjusted"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["payments"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["dues"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["closed"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["paid"] and
                previous_job_status in ["invoiced"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["closed"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["payment_confirmation_pending"] and
                previous_job_status in ["invoiced"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["disputes"],
                  &{&1, &1 + 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(dashboard_meta.statistics["payments"]["count"], &{&1, &1 + 1})

              updated_statistics

            current_job_status in ["payment_confirmation_pending"] and
                previous_job_status in ["adjusted"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["dues"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["disputes"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["paid"] and
                previous_job_status in ["payment_confirmation_pending"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["disputes"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["closed"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["dispute"] and previous_job_status in ["paid", "closed"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["closed"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["disputes"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["paid", "finalized", "closed"] and
                previous_job_status in ["dispute"] ->
              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["disputes"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["closed"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            current_job_status in ["paid"] and
                previous_job_status in ["completed"] ->
              {_, dashboard_meta} =
                get_and_update_in(dashboard_meta.statistics["scheduled"]["count"], &{&1, &1 - 1})

              {_, dashboard_meta} =
                get_and_update_in(
                  dashboard_meta.statistics["scheduled"]["#{type}"]["scheduled"],
                  &{&1, &1 - 1}
                )

              {_, %{statistics: updated_statistics}} =
                get_and_update_in(
                  dashboard_meta.statistics["payments"]["#{type}"]["closed"],
                  &{&1, &1 + 1}
                )

              updated_statistics

            true ->
              dashboard_meta.statistics
          end

        case MetaData.update_meta_cmr(dashboard_meta, %{statistics: updated_statistics}) do
          {:ok, data} ->
            #            meta_data = cmr_meta_socket_processing(data)
            CoreWeb.Endpoint.broadcast("meta_cmr:user_id:#{user_id}", "meta_cmr", %{
              statistics: updated_statistics
            })

            {:ok, data}

          {:error, error} ->
            {:error, error}

          _ ->
            {:error, ["Unable to update Consumer meta"]}
        end

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        {:ok, ["valid"]}
    end
  end

  def update_bsp_promotion_meta(branch_id) do
    count = Core.Promotions.get_active_promotions_count_by_branch(branch_id)

    case Employees.get_employee_by_role_and_branch(branch_id, "owner") do
      [%{id: employee_id}] ->
        case MetaData.get_dashboard_meta_by_employee_id(employee_id, branch_id, "dashboard") do
          [] ->
            {:ok, ["valid"]}

          [data] ->
            {_, %{statistics: updated_statistics}} =
              get_and_update_in(data.statistics["promos"]["count"], &{&1, count})

            case MetaData.update_meta_bsp(data, %{statistics: updated_statistics}) do
              {:ok, data} ->
                Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_bsp_socket: "*")

                #                meta_data  = Map.drop(data, [:__meta__, :__struct__, :user, :branch, :employee])
                CoreWeb.Endpoint.broadcast("meta_bsp:employee_id:#{employee_id}", "meta_bsp", %{
                  statistics: updated_statistics
                })

                {:ok, data}

              _ ->
                {:ok, ["valid"]}
            end
        end

      _ ->
        {:error, ["error while getting branch owner"]}
    end
  end

  def update_meta_for_employee(branch, employee_role) do
    with cs_ids <- Services.get_country_services_by_branch_id(branch.id),
         %{id: employee_id, user_id: user_id} <-
           Employees.get_by_branch_id(branch.id, employee_role),
         count <-
           Bids.get_bidding_jobs_count(%{
             country_service_ids: cs_ids,
             user_id: user_id,
             branch_coordinates: branch.location
           }),
         [meta] <-
           MetaData.get_dashboard_meta_by_employee_id(employee_id, branch.id, "dashboard"),
         {_, requests} <-
           get_and_update_in(
             meta.statistics["proposals"]["requests"],
             &{&1, count}
           ),
         {_, updated_statistics} <-
           get_and_update_in(
             requests.statistics["proposals"]["count"],
             &{&1, count}
           ),
         {:ok, _data} <-
           MetaData.update_meta_bsp(meta, %{statistics: updated_statistics.statistics}) do
      CoreWeb.Endpoint.broadcast(
        "meta_bsp:employee_id:#{employee_id}",
        "meta_bsp",
        %{statistics: updated_statistics}
      )
    else
      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["unable to update branch!"]}
    end
  end
end
