defmodule TudoChatWeb.GraphQL.Resolvers.GroupResolver do
  @moduledoc false
  use TudoChatWeb.GraphQL, :resolver
  import Ecto.Query, warn: false
  alias TudoChat.{Groups, Messages}
  alias TudoChatWeb.Controllers.GroupController

  @default_error ["unexpected error occurred"]

  def groups(_, _, %{context: %{current_user: _current_user}}) do
    {:ok, Groups.list_groups()}
  end

  def group_statuses(_, _, %{context: %{current_user: _current_user}}) do
    {:ok, Groups.list_group_statuses()}
  end

  def create_group(_, %{input: %{rest_profile_pic: pp} = input}, %{
        context: %{current_user: current_user}
      }) do
    params = Map.merge(input, %{created_by_id: current_user.id, profile_pic: pp})

    case GroupController.create_group(params) do
      {:ok, group} -> {:ok, group}
      {:error, error} -> {:error, error}
      _ -> {:error, ["error in creating my net chat group"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def create_group(_, %{input: input}, %{context: %{current_user: current_user}}) do
    params = Map.merge(input, %{created_by_id: current_user.id})

    case GroupController.create_group(params) do
      {:ok, group} -> {:ok, group}
      {:error, error} -> {:error, error}
      _ -> {:error, ["error in creating my net chat group"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_group(_, %{input: %{id: id} = input}, %{context: %{current_user: current_user}}) do
    if valid_for_update_group(input, current_user.id) do
      case Groups.get_group(id) do
        nil -> {:error, ["chat group not found"]}
        %{} = group -> updating_chat_group(group, input)
        _ -> {:error, ["error in getting chat group for updating"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  defp updating_chat_group(group, %{rest_profile_pic: profile_pic} = params) do
    case Groups.update_group(group, Map.merge(params, %{profile_pic: profile_pic})) do
      {:ok, group} -> {:ok, group}
      {:error, error} -> {:error, error}
    end
  end

  defp updating_chat_group(group, params) do
    case Groups.update_group(group, params) do
      {:ok, group} -> {:ok, group}
      {:error, error} -> {:error, error}
    end
  end

  def get_group(_, %{input: %{group_id: group_id}}, %{context: %{current_user: _current_user}}) do
    #    input = Map.merge(input, %{user_id: current_user.id})
    case TudoChatWeb.Controllers.MessageController.preload_group_with_members_and_user(group_id) do
      nil -> {:error, ["chat group not found"]}
      %{} = group -> {:ok, group}
    end
  rescue
    _all -> {:error, ["unexpected error occurred"]}
  end

  def get_groups_by(_, %{input: input}, %{context: %{current_user: %{id: user_id}}}) do
    case getting_chat_groups_by(Map.merge(input, %{user_id: user_id})) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def get_groups_by(_, _, %{context: %{current_user: %{id: user_id}}}) do
    case getting_chat_groups_by(%{user_id: user_id}) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  defp getting_chat_groups_by(input) do
    case Groups.get_groups_for_listing(input) do
      [] ->
        {:error, ["chat group not found"]}

      groups ->
        groups = get_filtered_groups(groups, input)

        if groups == [] do
          {:error, ["chat group not found"]}
        else
          groups =
            Enum.map(groups, fn %{id: group_id, service_request_id: sr_id, group_members: gm} =
                                  group ->
              job =
                if is_nil(sr_id) do
                  nil
                else
                  get_jobs_by_sr_id(sr_id)
                end

              count =
                Messages.get_unread_messages_count_by_group_and_user(%{
                  group_id: group_id,
                  user_id: input.user_id
                })

              last_message = Messages.get_last_message_by_group_and_user(group_id, input.user_id)

              Map.merge(group, %{
                unread_message_count: count,
                job: job,
                user_group_members: get_user_groups_memebr(gm),
                last_message: last_message
              })
            end)

          {:ok, groups}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def get_jobs_by_sr_id(sr_id) do
    case Core.Jobs.get_job(sr_id) do
      %{
        job_status_id: _job_status,
        inserted_by: cmr_id,
        branch_service_id: bs_id,
        branch_service_ids: bs_ids
      } = job ->
        if is_nil(bs_ids) || bs_ids == [] do
          Map.merge(job, %{
            branch: apply(Core.BSP, :get_branch_by_branch_service, [bs_id]),
            cmr: apply(Core.Accounts, :get_user!, [cmr_id])
          })
        else
          Map.merge(job, %{
            branch: apply(Core.BSP, :get_branch_by_branch_service, [List.first(bs_ids)]),
            cmr: Core.Accounts.get_user!(cmr_id)
          })
        end

      _ ->
        nil
    end
  end

  def get_user_groups_memebr(gm) do
    Enum.reduce(gm, [], fn
      %{user_id: user_id} = group_member, acc ->
        [Map.merge(group_member, %{user: Core.Accounts.get_user!(user_id)}) | acc]

      _, acc ->
        acc
    end)
  end

  #
  #  def get_groups_by _, %{input: input}, %{context: %{current_user: %{id: user_id}}} do
  #    input = Map.merge(input, %{user_id: user_id})
  #    case Groups.get_groups_by(input) do
  #      [] -> {:error, ["chat group not found"]}
  #      groups ->
  #        last_message = from(m in ComGroupMessage, order_by: [desc: m.inserted_at])
  #        groups = Enum.map(groups, &TudoChat.Repo.preload(&1, [last_message: last_message]))
  #        groups=Enum.map(groups, fn %{id: group_id, service_request_id: sr_id} = group ->
  #          job_status = if is_nil(sr_id) do
  #            nil
  #          else
  #            case Core.Jobs.get_job(sr_id) do
  #              %{job_status_id: job_status} -> job_status
  #              _ -> nil
  #            end
  #          end
  #          count = Messages.get_unread_messages_count_by_group_and_user(%{group_id: group_id, user_id: user_id})
  #          Map.merge(group, %{unread_message_count: count, job_status_id: job_status})
  #        end)
  #        {:ok, groups}
  #    end
  #  rescue
  #    _ ->
  #      {:error, ["unexpected error occurred"]}
  #  end
  #
  #  def get_groups_by _, _, %{context: %{current_user: %{id: user_id}}} do
  #    case Groups.get_groups_by(%{user_id: user_id}) do
  #      [] -> {:error, ["chat group not found"]}
  #      groups ->
  #        last_message = from(m in ComGroupMessage, order_by: [desc: m.inserted_at])
  #        groups = Enum.map(groups, &TudoChat.Repo.preload(&1, [last_message: last_message]))
  #        groups=Enum.map(groups, fn %{id: group_id, service_request_id: sr_id} = group ->
  #          job_status = if is_nil(sr_id) do
  #            nil
  #          else
  #            case Core.Jobs.get_job(sr_id) do
  #              %{job_status_id: job_status} -> job_status
  #              _ -> nil
  #            end
  #          end
  #          count = Messages.get_unread_messages_count_by_group_and_user(%{group_id: group_id, user_id: user_id})
  #          Map.merge(group, %{unread_message_count: count, job_status_id: job_status})
  #        end)
  #        {:ok, groups}
  #    end
  # rescue
  #   exception ->
  #     logger(__MODULE__, exception, @default_error, __ENV__.line)
  #  end

  def valid_for_update_group(%{id: id}, user_id) do
    case Groups.get_group_member_by(%{
           user_id: user_id,
           group_id: id,
           role_ids: ["super_admin", "admin"]
         }) do
      [] -> false
      _ -> true
    end
  end

  def create_group_status(_, %{input: %{id: id} = input}, _) do
    case Groups.get_group_status(id) do
      nil -> Groups.create_group_status(input)
      %{} -> {:error, ["chat Group status already exist"]}
      _ -> [:error, ["something went wrong"]]
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_group_status(_, %{input: %{id: id} = input}, _) do
    case Groups.get_group_status(id) do
      nil -> {:error, ["chat group status doesn't exist"]}
      %{} = status -> Groups.update_group_status(status, input)
      _ -> [:error, ["something went wrong"]]
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def get_group_status(_, %{input: %{id: id}}, _) do
    case Groups.get_group_status(id) do
      nil -> {:error, ["chat group status doesn't exist"]}
      %{} = status -> {:ok, status}
      _ -> [:error, ["something went wrong"]]
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def delete_group_status(_, %{input: %{id: id}}, _) do
    case Groups.get_group_status(id) do
      nil -> {:error, ["chat group status doesn't exist"]}
      %{} = status -> Groups.delete_group_status(status)
      _ -> [:error, ["something went wrong"]]
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def get_filtered_groups(groups, %{branch_id: _branch_id}), do: groups

  @doc """
  groups for bsp are removed from list if bsp not provided branch_id in params
  as busNet groups getting branch basis
  If a BSP post a job to another BSP then this BSP behave like a CMR and this filter funcion
  removes those group in which this BSP act as a BSP thus only my_net for this BSP(act as CMR)
  will shown.
  """

  def get_filtered_groups(groups, %{user_id: user_id}) do
    Enum.reduce(groups, [], fn
      %{created_by_id: cmr_id, group_type_id: "bus_net"} = group, acc when is_integer(cmr_id) ->
        if cmr_id == user_id, do: acc ++ [group], else: acc

      group, acc ->
        acc ++ [group]
    end)
  end
end
