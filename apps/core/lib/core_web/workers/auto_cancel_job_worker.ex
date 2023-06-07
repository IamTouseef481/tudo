defmodule CoreWeb.Workers.AutoCancelJobWorker do
  @moduledoc false

  import CoreWeb.Utils.Errors

  alias Core.Jobs
  alias Core.Jobs.JobNotificationHandler
  alias CoreWeb.Helpers.JobHelper

  def perform(id) do
    case Jobs.get_job(id) do
      nil ->
        {:ok, ["no job to be cancelled!"]}

      #      if rescheduled no action to be performed, as new job enqueued at reschedule
      %{job_cmr_status_id: "accept"} ->
        {:ok, [""]}

      %{job_bsp_status_id: "accept"} ->
        {:ok, [""]}

      #      %{job_cmr_status_id: "reject"} -> {:ok, [""]}
      #      %{job_bsp_status_id: "reject"} -> {:ok, [""]}
      #      auto cancel job as no action done
      %{job_status_id: "confirmed"} = job ->
        params = %{
          job_status_id: "cancelled",
          job_bsp_status_id: "cancelled",
          job_cmr_status_id: "cancelled",
          id: job.id
        }

        with {:ok, _, %{job: job, is_job_exist: previous_job, rescheduling_statuses: params}} <-
               JobHelper.update_job(params),
             _ <-
               JobNotificationHandler.send_notification_for_update_job(previous_job, job, params) do
          {:ok, job}
        else
          {:error, error} -> {:error, error}
        end

      _ ->
        {:ok, ["no need to auto cancel job, some action performed"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["could not auto cancel job"], __ENV__.line)
  end
end
