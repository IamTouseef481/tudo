defmodule CoreWeb.Workers.ChatGroupUpdateWorker do
  @moduledoc false
  alias Core.{BSP, Jobs, Payments}

  def perform(job_id, status, recheck_package \\ false) do
    if recheck_package do
      case Jobs.get_job(job_id) do
        %{branch_service_id: branch_service_id} ->
          recheck_subscription_package(job_id, branch_service_id, status)

        _ ->
          update_chat_group_status(job_id, status)
      end
    else
      update_chat_group_status(job_id, status)
    end
  end

  defp recheck_subscription_package(job_id, branch_service_id, status) do
    case BSP.get_business_by_branch_service_id(branch_service_id) do
      %{id: business_id} ->
        case Payments.get_brain_tree_subscription_by_business(business_id) do
          [] ->
            update_chat_group_status(job_id, status)

          [%{subscription_bsp_rule: %{package_id: "free"}}] ->
            update_chat_group_status(job_id, status)

          [%{status_id: "active", subscription_bsp_rule: %{data_retention: data_retention}}] ->
            Exq.enqueue_at(
              Exq,
              "default",
              Timex.shift(DateTime.utc_now(), months: data_retention),
              "CoreWeb.Workers.ChatGroupUpdateWorker",
              [job_id, "archive", true]
            )

          _ ->
            update_chat_group_status(job_id, status)
        end
    end
  end

  defp update_chat_group_status(job_id, status) do
    case apply(TudoChat.Groups, :get_group_by, [%{service_request_id: job_id}]) do
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
end
