defmodule CoreWeb.Helpers.JobStatusesHelper do
  #   Core.Jobs.StatusesHelper

  @moduledoc false

  import CoreWeb.Utils.Errors

  alias Core.{BSP, Services}
  alias CoreWeb.Controllers.SearchBSPController
  alias CoreWeb.Utils.Helpers

  def handle_job_status(
        %{
          waiting_ewd: waiting_ewd,
          waiting_arrive_at: waiting_arrive_at,
          time_change_request_by: request_by
        } = old_job,
        %{approve_time_request: approved?} = params
      )
      when waiting_ewd != nil and waiting_arrive_at != nil do
    approved_job_status_id =
      case params do
        %{job_status_id: status} -> status
        _ -> "confirmed"
      end

    approved_job_cmr_status_id =
      case params do
        %{job_cmr_status_id: status} ->
          status

        _ ->
          if request_by == "bsp" do
            if approved?, do: "accept", else: "reject"
          else
            "confirmed"
          end
      end

    approved_job_bsp_status_id =
      case params do
        %{job_bsp_status_id: status} ->
          status

        _ ->
          if request_by == "cmr" do
            if approved?, do: "accept", else: "reject"
          else
            "confirmed"
          end
      end

    arrive_at = if approved?, do: old_job.waiting_arrive_at, else: old_job.arrive_at
    ewd = if approved?, do: old_job.waiting_ewd, else: old_job.expected_work_duration

    status = %{
      expected_work_duration: ewd,
      arrive_at: arrive_at,
      time_change_request_by: nil,
      waiting_ewd: nil,
      waiting_arrive_at: nil,
      job_status_id: approved_job_status_id,
      job_bsp_status_id: approved_job_bsp_status_id,
      job_cmr_status_id: approved_job_cmr_status_id,
      old_job_status_id: nil
    }

    params |> Map.merge(status)
  end

  def handle_job_status(
        %{
          waiting_ewd: waiting_ewd,
          waiting_arrive_at: waiting_arrive_at,
          time_change_request_by: request_by
        } = old_job,
        %{approve_time_request: approved?} = params
      )
      when waiting_ewd == nil and waiting_arrive_at != nil do
    approved_job_status_id =
      case params do
        %{job_status_id: status} -> status
        _ -> "confirmed"
      end

    approved_job_cmr_status_id =
      case params do
        %{job_cmr_status_id: status} ->
          status

        _ ->
          if request_by == "bsp" do
            if approved?, do: "accept", else: "reject"
          else
            "confirmed"
          end
      end

    approved_job_bsp_status_id =
      case params do
        %{job_bsp_status_id: status} ->
          status

        _ ->
          if request_by == "cmr" do
            if approved?, do: "accept", else: "reject"
          else
            "confirmed"
          end
      end

    arrive_at = if approved?, do: old_job.waiting_arrive_at, else: old_job.arrive_at

    status = %{
      arrive_at: arrive_at,
      time_change_request_by: nil,
      waiting_arrive_at: nil,
      job_status_id: approved_job_status_id,
      job_bsp_status_id: approved_job_bsp_status_id,
      job_cmr_status_id: approved_job_cmr_status_id,
      old_job_status_id: nil
    }

    params |> Map.merge(status)
  end

  def handle_job_status(
        %{
          waiting_ewd: waiting_ewd,
          waiting_arrive_at: waiting_arrive_at,
          time_change_request_by: request_by
        } = old_job,
        %{approve_time_request: approved?} = params
      )
      when waiting_ewd != nil and waiting_arrive_at == nil do
    approved_job_status_id =
      case params do
        %{job_status_id: status} -> status
        _ -> "confirmed"
      end

    approved_job_cmr_status_id =
      case params do
        %{job_cmr_status_id: status} ->
          status

        _ ->
          if request_by == "bsp" do
            if approved?, do: "accept", else: "reject"
          else
            "confirmed"
          end
      end

    approved_job_bsp_status_id =
      case params do
        %{job_bsp_status_id: status} ->
          status

        _ ->
          if request_by == "cmr" do
            if approved?, do: "accept", else: "reject"
          else
            "confirmed"
          end
      end

    ewd = if approved?, do: old_job.waiting_ewd, else: old_job.expected_work_duration

    status = %{
      expected_work_duration: ewd,
      time_change_request_by: nil,
      waiting_ewd: nil,
      job_status_id: approved_job_status_id,
      job_bsp_status_id: approved_job_bsp_status_id,
      job_cmr_status_id: approved_job_cmr_status_id,
      old_job_status_id: nil
    }

    params |> Map.merge(status)
  end

  def handle_job_status(
        %{job_status_id: old_job_status} = _old_job,
        %{time_change_request_by: request_by} = params
      ) do
    waiting_job_status_id =
      case params do
        %{job_status_id: status} -> status
        _ -> "waiting"
      end

    waiting_job_cmr_status_id =
      case params do
        %{job_cmr_status_id: status} -> status
        _ -> if request_by == "bsp", do: "accept_reject", else: "waiting"
      end

    waiting_job_bsp_status_id =
      case params do
        %{job_bsp_status_id: status} -> status
        _ -> if request_by == "cmr", do: "accept_reject", else: "waiting"
      end

    status = %{
      job_status_id: waiting_job_status_id,
      job_bsp_status_id: waiting_job_bsp_status_id,
      job_cmr_status_id: waiting_job_cmr_status_id,
      old_job_status_id: old_job_status
    }

    params |> Map.merge(status)
  end

  def handle_job_status(
        %{job_status_id: old_job_status} = _old_job,
        %{job_status_id: _job_status} = params
      ) do
    status =
      case old_job_status do
        "cancelled" ->
          %{
            job_status_id: "cancelled",
            job_bsp_status_id: "cancelled",
            job_cmr_status_id: "cancelled"
          }

        _ ->
          %{}
      end

    params |> Map.merge(status)
  end

  def handle_job_status(_old_job, params), do: params

  #  for job statuses
  def job_status_verification(current_status, upcoming_status) do
    possible_statuses =
      cond do
        current_status == "pending" ->
          ["confirmed", "rejected", "waiting"]

        current_status == "waiting" ->
          ["cancelled", "confirmed", "rejected"]

        current_status == "confirmed" ->
          ["cancelled", "waiting", "started_heading", "started_working", "picked"]

        current_status == "started_working" ->
          ["completed", "cancelled", "waiting"]

        current_status == "picked" ->
          ["started_working"]

        current_status == "completed" ->
          ["invoiced"]

        current_status == "invoiced" ->
          ["paid", "invoiced"]

        current_status == "paid" ->
          ["closed", "finalized"]

        current_status == "closed" ->
          ["finalized"]

        true ->
          []
      end

    if upcoming_status in possible_statuses do
      {:ok, ["valid"]}
    else
      {:error, ["You can't update #{upcoming_status} Job status after #{current_status}"]}
    end
  end

  #  for job statuses with non positive invoice amount
  def job_status_verification(current_status, upcoming_status, _is_invoice_amount_non_positive) do
    possible_statuses =
      cond do
        current_status == "completed" ->
          ["paid"]

        true ->
          []
      end

    if upcoming_status in possible_statuses do
      {:ok, ["valid"]}
    else
      {:error, ["You can't update #{upcoming_status} Job status after #{current_status}"]}
    end
  end

  #  for job cmr statuses
  def job_cmr_status_verification(current_status, upcoming_status) do
    possible_statuses =
      cond do
        current_status == "waiting" ->
          ["cancelled", "confirmed", "rejected", "accept_reject"]

        current_status == "rejected" ->
          ["waiting"]

        current_status == "confirmed" ->
          ["waiting", "cancelled", "on_way", "on_board", "accept_reject", "picked"]

        current_status == "accept_reject" ->
          ["accept", "reject", "confirmed", "cancelled", "rejected", "waiting", "on_board"]

        current_status == "accept" ->
          ["confirmed", "cancelled", "rejected", "waiting", "on_board", "picked"]

        current_status == "reject" ->
          ["confirmed", "cancelled", "rejected", "waiting", "on_board", "picked"]

        current_status == "on_way" ->
          ["waiting", "accept_reject", "cancelled", "on_board", "accept", "reject"]

        current_status == "on_board" ->
          ["completed", "accept_reject", "cancelled", "accept", "reject"]

        current_status == "picked" ->
          ["on_board"]

        current_status == "completed" ->
          ["invoiced"]

        current_status == "invoiced" ->
          ["adjust_invoice", "paid", "payment_confirmation_pending"]

        current_status == "adjust_invoice" ->
          ["adjusted", "invoiced"]

        current_status == "adjusted" ->
          ["paid", "adjust_invoice", "payment_confirmation_pending"]

        current_status == "payment_confirmation_pending" ->
          ["paid"]

        current_status == "paid" ->
          ["dispute", "finalized"]

        current_status == "dispute" ->
          ["closed", "finalized"]

        current_status == "closed" ->
          ["finalized"]

        true ->
          []
      end

    if upcoming_status in possible_statuses do
      {:ok, ["valid"]}
    else
      {:error,
       ["You can't update #{upcoming_status} Job Consumer status after #{current_status}"]}
    end
  end

  #  for job cmr statuses with invoice amount non_positive
  def job_cmr_status_verification(
        current_status,
        upcoming_status,
        _is_invoice_amount_non_positive
      ) do
    possible_statuses =
      cond do
        current_status == "completed" ->
          ["paid"]

        true ->
          []
      end

    if upcoming_status in possible_statuses do
      {:ok, ["valid"]}
    else
      {:error,
       ["You can't update #{upcoming_status} Job Consumer status after #{current_status}"]}
    end
  end

  #  for job cmr statuses
  def job_bsp_status_verification(current_status, upcoming_status) do
    possible_statuses =
      cond do
        current_status == "waiting" ->
          ["accept", "reject", "confirmed", "cancelled", "accept_reject", "on_board"]

        current_status == "rejected" ->
          ["waiting"]

        current_status == "confirmed" ->
          ["waiting", "on_board", "on_way", "cancelled", "accept_reject", "picked"]

        current_status == "accept_reject" ->
          ["accept", "reject", "confirmed", "cancelled", "rejected", "waiting"]

        current_status == "accept" ->
          ["confirmed", "cancelled", "rejected", "waiting", "on_board", "picked"]

        current_status == "reject" ->
          ["confirmed", "cancelled", "rejected", "waiting", "on_board", "picked"]

        current_status == "on_way" ->
          ["waiting", "on_board", "accept_reject", "cancelled"]

        current_status == "on_board" ->
          ["waiting", "invoiced", "cancelled", "completed"]

        current_status == "picked" ->
          ["on_board"]

        current_status == "completed" ->
          ["invoiced"]

        current_status == "invoiced" ->
          ["adjust_invoice", "paid", "payment_confirmation_pending"]

        current_status == "adjust_invoice" ->
          ["adjusted", "invoiced"]

        current_status == "adjusted" ->
          ["paid", "adjust_invoice", "payment_confirmation_pending"]

        current_status == "payment_confirmation_pending" ->
          ["paid"]

        current_status == "paid" ->
          ["dispute", "finalized"]

        current_status == "dispute" ->
          ["closed", "finalized"]

        current_status == "closed" ->
          ["finalized"]

        true ->
          []
      end

    if upcoming_status in possible_statuses do
      {:ok, ["valid"]}
    else
      {:error,
       [
         "you can not update #{upcoming_status} Job Service Provider status after #{current_status}"
       ]}
    end
  end

  #  for job cmr statuses with invoice amount non_positive
  def job_bsp_status_verification(
        current_status,
        upcoming_status,
        _is_invoice_amount_non_positive
      ) do
    possible_statuses =
      cond do
        current_status == "completed" ->
          ["paid"]

        true ->
          []
      end

    if upcoming_status in possible_statuses do
      {:ok, ["valid"]}
    else
      {:error,
       [
         "you can not update #{upcoming_status} Job Service Provider status after #{current_status}"
       ]}
    end
  end

  def verify_job_status(
        job,
        %{
          job_status_id: job_status,
          job_bsp_status_id: job_bsp_status,
          job_cmr_status_id: job_cmr_status,
          is_invoice_amount_non_positive: true
        } = _params
      ) do
    with {:ok, _data} <- job_status_verification(job.job_status_id, job_status, true),
         {:ok, _data} <- job_cmr_status_verification(job.job_cmr_status_id, job_cmr_status, true),
         {:ok, data} <- job_bsp_status_verification(job.job_bsp_status_id, job_bsp_status, true) do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["error in verify job status"]}
    end
  end

  def verify_job_status(
        job,
        %{
          job_status_id: job_status,
          job_bsp_status_id: job_bsp_status,
          job_cmr_status_id: job_cmr_status
        } = _params
      ) do
    with {:ok, _data} <- job_status_verification(job.job_status_id, job_status),
         {:ok, _data} <- job_cmr_status_verification(job.job_cmr_status_id, job_cmr_status),
         {:ok, data} <- job_bsp_status_verification(job.job_bsp_status_id, job_bsp_status) do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["error in verify job status"]}
    end
  end

  def verify_job_status(
        job,
        %{job_bsp_status_id: job_bsp_status, job_cmr_status_id: job_cmr_status} = _params
      ) do
    with {:ok, _data} <- job_cmr_status_verification(job.job_cmr_status_id, job_cmr_status),
         {:ok, data} <- job_bsp_status_verification(job.job_bsp_status_id, job_bsp_status) do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["error in verify job status"]}
    end
  end

  def verify_job_status(
        job,
        %{job_status_id: job_status, job_cmr_status_id: job_cmr_status} = _params
      ) do
    with {:ok, _data} <- job_status_verification(job.job_status_id, job_status),
         {:ok, data} <- job_cmr_status_verification(job.job_cmr_status_id, job_cmr_status) do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["error in verify job status"]}
    end
  end

  def verify_job_status(
        job,
        %{job_status_id: job_status, job_bsp_status_id: job_bsp_status} = _params
      ) do
    with {:ok, _data} <- job_status_verification(job.job_status_id, job_status),
         {:ok, data} <- job_bsp_status_verification(job.job_bsp_status_id, job_bsp_status) do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["error in verify job status"]}
    end
  end

  def verify_job_status(job, %{job_status_id: job_status} = _params) do
    case job_status_verification(job.job_status_id, job_status) do
      {:ok, data} ->
        {:ok, data}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Every in verifying job status"], __ENV__.line)
    end
  end

  def verify_job_status(job, %{job_bsp_status_id: job_bsp_status} = _params) do
    case job_bsp_status_verification(job.job_bsp_status_id, job_bsp_status) do
      {:ok, data} ->
        {:ok, data}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Every in verifying job status"], __ENV__.line)
    end
  end

  def verify_job_status(job, %{job_cmr_status_id: job_cmr_status} = _params) do
    case job_cmr_status_verification(job.job_cmr_status_id, job_cmr_status) do
      {:ok, data} ->
        {:ok, data}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Every in verifying job status"], __ENV__.line)
    end
  end

  def verify_job_status(_, _) do
    {:ok, ["valid"]}
  end

  def verify_provider_on_reschedule(
        job,
        %{waiting_arrive_at: waiting_arrive_at, waiting_ewd: waiting_ewd} = _params
      ) do
    params = %{arrive_at: waiting_arrive_at, expected_work_duration: waiting_ewd}
    verifying_provider_on_reschedule(job, params)
  end

  def verify_provider_on_reschedule(
        %{expected_work_duration: ewd} = job,
        %{waiting_arrive_at: waiting_arrive_at} = _params
      ) do
    params = %{arrive_at: waiting_arrive_at, expected_work_duration: ewd}
    verifying_provider_on_reschedule(job, params)
  end

  def verify_provider_on_reschedule(
        %{arrive_at: arrive_at} = job,
        %{waiting_ewd: waiting_ewd} = _params
      ) do
    params = %{arrive_at: arrive_at, expected_work_duration: waiting_ewd}
    verifying_provider_on_reschedule(job, params)
  end

  def verify_provider_on_reschedule(_job, _params) do
    {:ok, ["no need to check provider availability"]}
  end

  defp verifying_provider_on_reschedule(%{location_dest: location_dest} = job, params) do
    params =
      if is_nil(job.branch_service_ids) do
        add_branch_service_data(params, job.branch_service_id)
      else
        add_branch_service_data(params, job.branch_service_ids)
      end

    params = Map.merge(params, %{location_dest: location_dest})
    bsp = BSP.get_branch_by_search(params)

    case SearchBSPController.filter_bsps_by_availability(bsp, params) do
      %{input: input, bsps: bsps} ->
        if bsps == [] do
          {:error, ["Selected Service Provider is not available right now, please search again!"]}
        else
          {:ok, input}
        end

      _ ->
        {:error, ["Something went wrong while searching Service Provider, please try again"]}
    end
  end

  defp add_branch_service_data(params, ids) do
    case Services.get_branch_service(ids) do
      nil ->
        params

      [] ->
        params

      data ->
        if is_list(data) do
          cs_ids = Helpers.get(data, :country_service_id)

          branch_ids =
            Helpers.get(data, :branch_id)
            |> Enum.uniq()

          service_ids = Services.list_services_ids_by_cs_ids(cs_ids)

          Map.merge(params, %{
            country_service_ids: cs_ids,
            service_ids: service_ids,
            branch_ids: branch_ids
          })
        else
          cs_id = data.country_service_id
          %{service_id: service_id} = Services.get_country_service(cs_id)

          Map.merge(params, %{
            branch_id: data.branch_id,
            service_id: service_id,
            country_service_id: cs_id
          })
        end
    end
  end

  def auto_finalize_job_after_payment(%{job_id: job_id} = params) do
    days = if params[:get_insured], do: 90, else: 10
    #    time = Timex.shift(DateTime.utc_now(), seconds: 30)
    time = Timex.shift(DateTime.utc_now(), days: days)

    Exq.enqueue_at(
      Exq,
      "default",
      time,
      "CoreWeb.Workers.JobStatusUpdateWorker",
      [
        job_id,
        %{
          job_status_id: "finalized",
          job_cmr_status_id: "finalized",
          job_bsp_status_id: "finalized"
        }
      ]
    )
  end
end
