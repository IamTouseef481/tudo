defmodule CoreWeb.Helpers.ChatGroupHelper do
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{Bids, BSP, Employees, Jobs, Payments, Services}
  alias TudoChat.Groups

  #
  # Main actions
  #
  @chat_group_error :chat_group_not_created

  def create_chat_group(params) do
    new()
    |> run(:chat_group, &create_chat_group/2, &abort/3)
    |> run(:archive_chat_group, &archive_chat_group/2, &abort/3)
    |> run(:add_group_id_in_job, &add_group_id_in_job/2, &abort/3)
    |> run(:group_members, &create_group_members/2, &abort/3)
    |> transaction(TudoChat.Repo, params)
  rescue
    exception ->
      logger(__MODULE__, exception, @chat_group_error, __ENV__.line)
  end

  # ------------------------user Group------------------------------------------------------------#
  def create_chat_user_group(params) do
    new()
    |> run(:chat_user_group, &create_chat_user_group/2, &abort/3)
    |> run(:group_user_members, &create_group_user_members/2, &abort/3)
    |> transaction(TudoChat.Repo, params)
  rescue
    exception ->
      logger(__MODULE__, exception, @chat_group_error, __ENV__.line)
  end

  def create_chat_user_group(_, user_id) do
    group_profile = %{
      thumb: "https://s3.amazonaws.com/tudoicons/Icons/TUDO_reduced_size.jpg",
      original: "https://s3.amazonaws.com/tudoicons/Icons/TUDO_reduced_size.jpg"
    }

    case apply(Groups, :create_group, [
           %{
             name: "TUDO Marketing",
             profile_pic: group_profile,
             created_by_id: user_id,
             marketing_group: true,
             group_type_id: "my_net",
             group_status_id: "active",
             created_at: DateTime.utc_now()
           }
         ]) do
      {:ok, res} -> {:ok, res}
      _ -> {:ok, ["TUDO Marketing chat group is not created"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @chat_group_error, __ENV__.line)
  end

  def create_group_user_members(%{chat_user_group: %{id: group_id}}, user_id) do
    params = %{group_id: group_id, user_id: user_id, is_active: true, role_id: "member"}

    case apply(Groups, :create_group_member, [params]) do
      {:ok, res} -> {:ok, res}
      _ -> {:error, ["TUDO Marketing chat group member is not created"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :chat_group_member_not_created, __ENV__.line)
  end

  # ------------------------user Group------------------------------------------------------------#

  def create_chat_group(_, %{bidding_proposal_id: proposal_id} = job) when is_nil(proposal_id) do
    group_profile_pic =
      case job do
        %{gallery: nil} -> nil
        %{gallery: []} -> nil
        %{gallery: gallery} -> if is_list(gallery), do: List.first(gallery), else: gallery
      end

    branch_service_id = job.branch_service_id || job.branch_service_ids

    if is_list(branch_service_id) do
      case List.first(branch_service_id) do
        nil ->
          nil

        bs_id ->
          case Services.get_branch_service(bs_id) do
            %{branch_id: branch_id} ->
              case apply(Groups, :create_group, [
                     %{
                       name: job.title,
                       service_request_id: job.id,
                       profile_pic: group_profile_pic,
                       created_by_id: job.inserted_by,
                       group_type_id: "bus_net",
                       group_status_id: "active",
                       branch_id: branch_id,
                       created_at: DateTime.utc_now()
                     }
                   ]) do
                {:ok, res} -> {:ok, res}
                _ -> {:ok, job}
              end

            _ ->
              nil
          end
      end
    else
      case branch_service_id do
        nil ->
          nil

        bs_id ->
          case Services.get_branch_service(bs_id) do
            %{branch_id: branch_id} ->
              case apply(Groups, :create_group, [
                     %{
                       name: job.title,
                       service_request_id: job.id,
                       profile_pic: group_profile_pic,
                       created_by_id: job.inserted_by,
                       group_type_id: "bus_net",
                       group_status_id: "active",
                       branch_id: branch_id,
                       created_at: DateTime.utc_now()
                     }
                   ]) do
                {:ok, res} -> {:ok, res}
                _ -> {:ok, job}
              end

            _ ->
              nil
          end
      end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @chat_group_error, __ENV__.line)
  end

  def create_chat_group(_, %{bidding_proposal_id: proposal_id} = job) do
    %{bidding_job_id: bid_id} = Bids.get_bid_proposal(proposal_id)
    groups = apply(Groups, :get_groups_by_bid, [%{bidding_job_id: bid_id}])

    remaining_group =
      Enum.reduce(groups, [], fn %{proposal_id: group_proposal_id} = group, acc ->
        if group_proposal_id != proposal_id do
          apply(Groups, :update_group, [group, %{group_status_id: "in_active"}])
          acc
        else
          [group | acc]
        end
      end)

    case remaining_group do
      [] -> create_chat_group("", Map.merge(job, %{bidding_proposal_id: nil}))
      [group] -> apply(Groups, :update_group, [group, %{service_request_id: job.id}])
      groups -> {:ok, List.last(groups)}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @chat_group_error, __ENV__.line)
  end

  def archive_chat_group(_, job) do
    branch_service_id = job.branch_service_id || job.branch_service_ids

    data_retention =
      if is_list(branch_service_id) do
        case List.first(branch_service_id) do
          %{id: business_id} ->
            case Payments.get_brain_tree_subscription_by_business(business_id) do
              [] ->
                case Payments.get_subscription_bsp_rule_by_package_and_country("free", 1) do
                  [%{data_retention: data_retention}] -> data_retention
                  _ -> 6
                end

              [%{subscription_bsp_rule: %{data_retention: data_retention}}] ->
                data_retention
            end

          _ ->
            6
        end
      else
        case branch_service_id do
          %{id: business_id} ->
            case Payments.get_brain_tree_subscription_by_business(business_id) do
              [] ->
                case Payments.get_subscription_bsp_rule_by_package_and_country("free", 1) do
                  [%{data_retention: data_retention}] -> data_retention
                  _ -> 6
                end

              [%{subscription_bsp_rule: %{data_retention: data_retention}}] ->
                data_retention
            end

          _ ->
            6
        end
      end

    Exq.enqueue_at(
      Exq,
      "default",
      Timex.shift(DateTime.utc_now(), months: data_retention),
      "CoreWeb.Workers.ChatGroupUpdateWorker",
      [job.id, "archive", true]
    )
  rescue
    _all -> {:ok, job}
  end

  def add_group_id_in_job(%{chat_group: %{id: group_id}}, job) do
    case Jobs.update_job(job, %{chat_group_id: group_id}) do
      {:ok, res} -> {:ok, res}
      _ -> {:ok, job}
    end
  end

  def create_group_members(
        %{chat_group: %{id: group_id} = chat_group},
        %{bidding_proposal_id: proposal_id} = job
      )
      when is_nil(proposal_id) do
    group_member_user_ids = make_group_member_params(job)

    #    Enum.filter is used to exclude nil values from list
    #    Enum.uniq is used to avoid add user multiple times in group

    group_member_user_ids =
      group_member_user_ids
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> remove_users_duplication()

    group_members =
      Enum.reduce(group_member_user_ids, [], fn {role, user_id}, acc ->
        params = %{group_id: group_id, user_id: user_id, is_active: true}

        params =
          case role do
            :business_owner ->
              params |> put(:role_id, "super_admin")

            :branch_owner ->
              params |> put(:role_id, "admin")

            :manager ->
              params |> put(:role_id, "admin")

            :employee ->
              params |> put(:role_id, "admin")

            :cmr ->
              params |> put(:role_id, "member")

            _ ->
              params |> put(:role_id, "member")
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

          {:error, _} ->
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

  def create_group_members(%{chat_group: %{id: group_id}} = chat_group, job) do
    employee_user_id =
      if job.employee_id == nil do
        nil
      else
        %{user_id: employee_user_id} = Employees.get_employee(job.employee_id)
        employee_user_id
      end

    group_member_user_ids = [employee: employee_user_id]

    #    Enum.filter is used to exclude nil values from list
    #    Enum.uniq is used to avoid add user multiple times in group

    _group_member_user_ids =
      group_member_user_ids
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> remove_users_duplication()

    case apply(Groups, :get_group_member_by, [%{group_id: group_id, user_id: employee_user_id}]) do
      [] ->
        member_params = %{
          group_id: group_id,
          user_id: employee_user_id,
          is_active: true,
          role_id: "member"
        }

        case apply(Groups, :create_group_member, [member_params]) do
          {:ok, member} ->
            apply(TudoChatWeb.Endpoint, :broadcast, [
              "user:user_id:#{member.user_id}",
              "group_created",
              %{
                chat_group:
                  apply(TudoChatWeb.Channels.UserChannel, :create_group_socket, [chat_group])
              }
            ])

            {:ok, member}

          _ ->
            {:ok, ["member can not created"]}
        end

      _ ->
        {:ok, ["employee already member"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @chat_group_error, __ENV__.line)
  end

  def make_group_member_params(job) do
    cmr_user_id = job.inserted_by

    %{user_id: employee_user_id} =
      if job.employee_id == nil do
        nil
      else
        %{user_id: _employee_user_id} = Employees.get_employee(job.employee_id)
      end

    branch_service_id = job.branch_service_id || job.branch_service_ids

    branch_id =
      if is_list(branch_service_id) do
        %{branch_id: branch_id} = Services.get_branch_service(List.first(job.branch_service_ids))
        branch_id
      else
        %{branch_id: branch_id} = Services.get_branch_service(job.branch_service_id)
        branch_id
      end

    # %{branch_id: branch_id} = Services.get_branch_service(job.branch_service_id)
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
      employee: employee_user_id,
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

  def update_chat_group_status(job, params) do
    case params do
      %{job_status_id: "finalized"} -> in_active_chat_group_status(job, "in_active")
      %{job_status_id: "cancelled"} -> in_active_chat_group_status(job, "closed")
      %{job_status_id: "ignored"} -> in_active_chat_group_status(job, "closed")
      %{job_status_id: "rejected"} -> updates_chat_group_status(job, "archive")
      _ -> {:ok, ["no needed to update chat group"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @chat_group_error, __ENV__.line)
  end

  def in_active_chat_group_status(job, status) do
    case apply(TudoChat.Groups, :get_group_by, [%{service_request_id: job.id}]) do
      [] ->
        {:ok, ["no group needed to be updated!"]}

      [group] ->
        case apply(TudoChat.Groups, :update_group, [group, %{group_status_id: status}]) do
          {:ok, group} -> {:ok, group}
          {:error, error} -> {:error, error}
          _ -> {:error, ["unexpected error occurred while updating group status!"]}
        end

      groups ->
        Enum.map(groups, &apply(TudoChat.Groups, :update_group, [&1, %{group_status_id: status}]))
    end
  end

  def updates_chat_group_status(job, status) do
    Exq.enqueue_at(
      Exq,
      "default",
      Timex.shift(DateTime.utc_now(), hours: 24),
      "CoreWeb.Workers.ChatGroupUpdateWorker",
      [job.id, status]
    )
  end
end
