defmodule CoreWeb.Controllers.CashPaymentController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.CashPayments
  alias CoreWeb.Helpers.CashPaymentHelper

  @default_error ["unexpected error occurred"]

  def create_cash_payment(%{invoice_id: invoice_id, cheque_amount: _} = input) do
    case CashPayments.get_cheque_payment_by_invoice(invoice_id) do
      [] -> creating_cash_payment(input)
      [%{} = cash_payment | _] -> {:ok, cash_payment}
    end
  end

  def create_cash_payment(%{invoice_id: invoice_id} = input) do
    case CashPayments.get_cash_payment_by_invoice(invoice_id) do
      [] -> creating_cash_payment(input)
      [%{} = cash_payment | _] -> {:ok, cash_payment}
    end
  end

  defp creating_cash_payment(%{employee_verified: true} = input) do
    case CashPaymentHelper.create_cash_payment(input) do
      {:ok, _last, %{update_job_for_pending_cash_payment: update_job_for_pending_cash_payment}} ->
        {:ok, update_job_for_pending_cash_payment}

      {:error, error} ->
        {:error, error}
    end
  end

  defp creating_cash_payment(input) do
    case CashPaymentHelper.create_cash_payment(input) do
      {:ok, _last, %{cash_payment: cash_payment, local_transaction: local_payment}} ->
        {:ok, Map.merge(cash_payment, %{payment_details: local_payment})}

      {:error, error} ->
        {:error, error}
    end
  end

  def generate_cash_payment(input) do
    case CashPaymentHelper.generate_cash_payment(input) do
      {:ok, _last, %{updated_cash_payment: cash_payment, local_transaction: local_payment}} ->
        {:ok, Map.merge(cash_payment, %{payment_details: local_payment})}

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def adjust_cash_payment(payment, %{payment_method_id: "cash"} = input) do
    case CashPayments.update_cash_payment(payment, input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def adjust_cash_payment(payment, %{payment_method_id: "cheque"} = input) do
    case CashPayments.update_cheque_payment(payment, input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_cash_payment(%{id: id, paid_amount: paid_amount} = input) do
    case CashPayments.get_cash_payment(id) do
      nil ->
        {:error, ["Cash Payment does not exist"]}

      %{pay_due_amount: payable_amount} = payment ->
        if paid_amount < payable_amount do
          {:error, ["Due amount is more than you are paying"]}
        else
          updates_cash_payment(payment, input)
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_cash_payment(%{id: id} = input) do
    case CashPayments.get_cheque_payment(id) do
      nil -> {:error, ["Cheque Payment does not exist"]}
      %{} = payment -> updates_cheque_payment(payment, input)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def updates_cash_payment(%{pay_due_amount: due_amount, invoice_id: invoice_id} = payment, %{
        paid_amount: paid_amount
      }) do
    CashPaymentHelper.cash_payment_socket(%{cash_payment: %{invoice_id: invoice_id}}, 1)

    {
      :ok,
      payment
      |> Map.merge(%{
        pay_due_amount: due_amount,
        paid_amount: paid_amount,
        returned_amount: paid_amount - due_amount
      })
    }
  end

  def updates_cheque_payment(
        %{pay_due_amount: _due_amount, invoice_id: invoice_id} = payment,
        %{paid_amount: _paid_amount} = input
      ) do
    CashPaymentHelper.cash_payment_socket(%{cash_payment: %{invoice_id: invoice_id}}, 1)

    {
      :ok,
      payment
      |> Map.merge(input)
    }
  end
end
