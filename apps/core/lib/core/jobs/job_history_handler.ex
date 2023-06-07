defmodule Core.Jobs.JobHistoryHandler do
  @moduledoc false
  alias Core.{Accounts, Invoices, Jobs, Payments}

  #  at create job
  def create_job_history(
        %{
          id: job_id,
          job_status_id: job_status_id,
          job_cmr_status_id: job_cmr_status_id,
          job_bsp_status_id: job_bsp_status_id
        },
        %{inserted_by: _inserted_by} = params
      ) do
    params =
      Map.merge(params, %{
        job_id: job_id,
        job_status_id: job_status_id,
        job_cmr_status_id: job_cmr_status_id,
        job_bsp_status_id: job_bsp_status_id,
        user_role: "cmr",
        created_at: DateTime.utc_now()
      })

    creates_job_history(params)
  end

  #  at any status change event
  def create_job_history(
        %{id: job_id, update_status_by: user_role, inserted_by: inserted_by},
        %{job_status_id: _} = params
      ) do
    invoice_id =
      case Invoices.get_invoice_by_job_id(job_id) do
        [%{id: invoice_id}] -> invoice_id
        _ -> nil
      end

    payment_id =
      case Payments.get_payment_by_job_id(job_id) do
        [] -> nil
        [%{id: payment_id}] -> payment_id
        payments -> List.last(payments).id
      end

    reason =
      case params do
        %{cancel_reason: reason} -> reason
        %{reason_for_time_change: reason} -> reason
        %{adjust_reason: reason} -> reason
        %{dispute_reason: reason} -> reason
        _ -> nil
      end

    params =
      Map.merge(params, %{
        job_id: job_id,
        inserted_by: inserted_by,
        reason: reason,
        user_role: user_role,
        invoice_id: invoice_id,
        payment_id: payment_id,
        created_at: DateTime.utc_now()
      })

    creates_job_history(params)
  end

  #  when main status is not in params, no need to create job history node
  def create_job_history(_job, _params) do
    {:ok, "no need to create job history"}
  end

  defp creates_job_history(params) do
    case Jobs.create_job_history(params) do
      {:ok, history} -> {:ok, history}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["error in creating job history"]}
    end
  end

  def get_user_role(user_id) do
    case Accounts.get_user!(user_id) do
      %{acl_role_id: user_roles} ->
        cond do
          "bsp" in user_roles -> "bsp"
          "emp" in user_roles -> "emp"
          "cmr" in user_roles -> "cmr"
          true -> nil
        end

      _ ->
        nil
    end
  end
end
