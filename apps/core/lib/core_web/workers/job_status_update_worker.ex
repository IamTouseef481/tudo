defmodule CoreWeb.Workers.JobStatusUpdateWorker do
  @moduledoc false
  import CoreWeb.Utils.Errors

  def perform(job_id, params) do
    logger(__MODULE__, job_id, :info, __ENV__.line)

    case Core.Jobs.get_job(job_id) do
      nil ->
        {:ok, ["no job to be updated!"]}

      %{
        job_status_id: "paid",
        job_bsp_status_id: "paid",
        job_cmr_status_id: "paid"
      } = job ->
        Core.Jobs.update_job(job, params)

      _ ->
        # TODO: If CMR status is not paid then may be the job is in disputes and something else.
        # Need to deal that case after finalized dispute macanisam.
        {:ok, ["No need to update"]}
    end
  end
end
