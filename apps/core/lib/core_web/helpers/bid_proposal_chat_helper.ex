defmodule CoreWeb.Helpers.BidProposalChatHelper do
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{Bids, BSP, Employees}
  alias TudoChat.Groups

  #
  # Main actions
  #
  @chat_group_error :chat_group_not_created

  def create_chat_group(params) do
    new()
    |> run(:chat_group, &create_chat_group/2, &abort/3)
    #    |> run(:archive_chat_group, &archive_chat_group/2, &abort/3)
    |> run(:add_group_id_in_proposal, &add_group_id_in_proposal/2, &abort/3)
    |> run(:group_members, &create_group_members/2, &abort/3)
    |> transaction(TudoChat.Repo, params)
  rescue
    exception ->
      logger(__MODULE__, exception, @chat_group_error, __ENV__.line)
  end

  # -----------------------------------------------

  def create_chat_group(
        _,
        %{user_id: _user_id, bidding_job_id: bidding_job_id, id: proposal_id} = proposal
      ) do
    with %{title: title, cmr_id: cmr_id} <- Bids.get_bidding_job(bidding_job_id),
         {:ok, res} <-
           apply(Groups, :create_group, [
             %{
               name: title,
               bid_id: bidding_job_id,
               proposal_id: proposal_id,
               profile_pic: proposal.profile_pic,
               created_by_id: cmr_id,
               group_type_id: "bus_net",
               group_status_id: "active",
               branch_id: proposal.branch_id,
               created_at: DateTime.utc_now()
             }
           ]) do
      {:ok, res}
    else
      _ -> {:error, :chat_group_not_created}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @chat_group_error, __ENV__.line)
  end

  #  def archive_chat_group(_, proposal) do
  #    data_retention=case BSP.get_business_by_branch_service_id(job.branch_service_id) do
  #      %{id: business_id} ->
  #        case Payments.get_brain_tree_subscription_by_business(business_id) do
  #          [] ->
  #            case Payments.get_subscription_bsp_rule_by_package_and_country("free", 1) do
  #              [%{data_retention: data_retention}] -> data_retention
  #              _ -> 6
  #            end
  #          [%{subscription_bsp_rule: %{data_retention: data_retention}}] -> data_retention
  #        end
  #      _ -> 6
  #    end
  #    Exq.enqueue_at(
  #      Exq,
  #      "default",
  #      Timex.shift(DateTime.utc_now(), months: data_retention),
  #      "CoreWeb.Workers.ChatGroupUpdateWorker",
  #      [job.id, "archive", true]
  #    )
  #  rescue
  #    all -> {:ok, job}
  #  end

  def add_group_id_in_proposal(%{chat_group: %{id: group_id}}, proposal) do
    case Bids.update_bid_proposal(proposal, %{chat_group_id: group_id}) do
      {:ok, res} -> {:ok, res}
      _ -> {:ok, proposal}
    end
  end

  def create_group_members(%{chat_group: %{id: group_id} = chat_group}, proposal) do
    group_member_user_ids = make_group_member_params(proposal)

    #    Enum.filter is used to exclude nil values from list
    #    Enum.uniq is used to avoid add user multiple times in group

    group_member_user_ids =
      group_member_user_ids
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> remove_users_duplication()

    group_members =
      Enum.reduce(group_member_user_ids, [], fn {role, user_id}, acc ->
        params =
          case role do
            :business_owner ->
              %{group_id: group_id, user_id: user_id, is_active: true, role_id: "super_admin"}

            :branch_owner ->
              %{group_id: group_id, user_id: user_id, is_active: true, role_id: "admin"}

            :manager ->
              %{group_id: group_id, user_id: user_id, is_active: true, role_id: "admin"}

            :employee ->
              %{group_id: group_id, user_id: user_id, is_active: true, role_id: "admin"}

            :cmr ->
              %{group_id: group_id, user_id: user_id, is_active: true, role_id: "member"}

            _ ->
              %{group_id: group_id, user_id: user_id, is_active: true, role_id: "member"}
          end

        case apply(Groups, :create_group_member, [params]) do
          {:ok, res} ->
            apply(TudoChatWeb.Endpoint, :broadcast, [
              "user:user_id:#{res.user_id}",
              "group_created",
              %{
                chat_group:
                  apply(TudoChatWeb.Channels.UserChannel, :create_group_socket, [chat_group])
              }
            ])

            [res | acc]

          {:error, _error} ->
            acc

          _ ->
            acc
        end
      end)

    {:ok, group_members}
  rescue
    exception ->
      logger(__MODULE__, exception, @chat_group_error, __ENV__.line)
  end

  def make_group_member_params(
        %{bidding_job_id: bidding_job_id, user_id: _user_id, branch_id: branch_id} = _proposal
      ) do
    cmr_user_id =
      case Bids.get_bidding_job(bidding_job_id) do
        %{cmr_id: cmr_id} -> cmr_id
        _ -> nil
      end

    %{user_id: business_owner_user_id} = BSP.get_business_by_branch_id(branch_id)

    branch_owner_user_id =
      case Employees.get_employee_by_role_and_branch(branch_id, "owner") do
        [%{user_id: branch_owner_user_id} | _employee] = _employees -> branch_owner_user_id
        _ -> nil
      end

    manager_user_id =
      case Employees.get_employee_by_role_and_branch(branch_id, "branch_manager") do
        [%{user_id: manager_user_id} | _employee] = _employees -> manager_user_id
        _ -> nil
      end

    [
      business_owner: business_owner_user_id,
      branch_owner: branch_owner_user_id,
      manager: manager_user_id,
      cmr: cmr_user_id
    ]
  end

  # user_ids is a keyword list
  defp remove_users_duplication(user_ids) do
    Enum.reduce(Keyword.keys(user_ids), user_ids, fn outer_key, outer_acc ->
      if Keyword.has_key?(outer_acc, outer_key) do
        user_ids_without_iterative = Keyword.delete(outer_acc, outer_key)

        Enum.reduce(user_ids_without_iterative, outer_acc, fn {inner_key, inner_val}, inner_acc ->
          if outer_acc[outer_key] == inner_val do
            Keyword.delete(inner_acc, inner_key)
          else
            inner_acc
          end
        end)
      else
        outer_acc
      end
    end)
  end

  #  def update_chat_group_status(job, params) do
  #    case params do
  #      %{job_status_id: "finalized"} -> in_active_chat_group_status(job, "in_active")
  #      %{job_status_id: "cancelled"} -> updates_chat_group_status(job, "archive")
  #      %{job_status_id: "rejected"} -> updates_chat_group_status(job, "archive")
  #      _ -> {:ok, ["no needed to update chat group"]}
  #    end
  #  rescue
  #    all ->
  #      {:error, :chat_group_not_updated}
  #  end

  #  def in_active_chat_group_status(job, status) do
  #    case TudoChat.Groups.get_group_by(%{service_request_id: job.id}) do
  #      [] -> {:ok, ["no group needed to be updated!"]}
  #      [group] ->
  #        case TudoChat.Groups.update_group(group, %{group_status_id: status}) do
  #          {:ok, group} -> {:ok, group}
  #          {:error, error} -> {:error, error}
  #          _ -> {:error, ["unexpected error occurred while updating group status!"]}
  #        end
  #    end
  #  end

  #  def updates_chat_group_status(job, status) do
  #    Exq.enqueue_at(
  #      Exq,
  #      "default",
  #      Timex.shift(DateTime.utc_now(), hours: 24),
  #      "CoreWeb.Workers.ChatGroupUpdateWorker",
  #      [job.id, status]
  #    )
  #  end
end
