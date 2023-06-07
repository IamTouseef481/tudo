defmodule CoreWeb.GraphQL.Resolvers.CashPaymentResolver do
  @moduledoc false
  import CoreWeb.Utils.Errors
  alias CoreWeb.Controllers.CashPaymentController
  alias CoreWeb.GraphQL.Resolvers.InvoiceResolver
  alias Core.{CashPayments, Jobs}

  @default_error ["unexpected error occurred"]

  def create_cash_payment(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case verify_for_create_cash_payment(input, current_user) do
      {:ok, input} -> CashPaymentController.create_cash_payment(input)
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  defp verify_for_create_cash_payment(%{invoice_id: invoice_id} = input, current_user) do
    input =
      Map.merge(input, %{
        country_id: current_user.country_id,
        user_id: current_user.id,
        user: current_user
      })

    case Jobs.get_job_by_invoice(invoice_id) do
      nil ->
        {:error, ["Invoice for this Job does not exists"]}

      %{id: job_id, inserted_by: cmr_id} ->
        cond do
          current_user.id == cmr_id ->
            {:ok, input}

          InvoiceResolver.employee_verified?(%{job_id: job_id, user_id: current_user.id}) ->
            {:ok, Map.merge(input, %{employee_verified: true, payment_method_id: "cash"})}

          true ->
            {:error, ["you are not permitted!"]}
        end
    end
  end

  def get_cash_payment_by_invoice(_, %{input: %{invoice_id: invoice_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    case Jobs.get_job_by_invoice(invoice_id) do
      nil ->
        {:error, ["Invoice for this Job does not exists"]}

      %{inserted_by: cmr_id, id: job_id} ->
        if InvoiceResolver.employee_verified?(%{job_id: job_id, user_id: current_user.id}) or
             current_user.id == cmr_id do
          getting_cash_payment(invoice_id, input)
        else
          {:error, ["you are not permitted!"]}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  defp getting_cash_payment(invoice_id, %{payment_method_id: "cheque"}) do
    case CashPayments.get_cheque_payment_by_invoice(invoice_id) do
      [] -> {:error, ["Cheque Payment does not exist"]}
      [%{} = payment | _] -> {:ok, payment}
    end
  end

  defp getting_cash_payment(invoice_id, _) do
    case CashPayments.get_cash_payment_by_invoice(invoice_id) do
      [] -> {:error, ["Cash Payment does not exist"]}
      [%{} = payment | _] -> {:ok, payment}
    end
  end

  def generate_cash_payment(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input =
      Map.merge(input, %{
        country_id: current_user.country_id,
        user_id: current_user.id,
        user: current_user
      })

    case CashPaymentController.generate_cash_payment(input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def adjust_cash_payment(_, %{input: %{id: id} = input}, %{
        context: %{current_user: current_user}
      }) do
    input =
      Map.merge(input, %{
        country_id: current_user.country_id,
        user_id: current_user.id,
        user: current_user
      })

    payment =
      case input do
        %{payment_method_id: "cheque"} -> Jobs.get_job_by_cheque_payment_id(id)
        %{payment_method_id: "cash"} -> Jobs.get_job_by_cash_payment_id(id)
        _ -> Jobs.get_job_by_cash_payment_id(id)
      end

    case payment do
      nil ->
        {:error, ["Invoice for this Job does not exists"]}

      %{inserted_by: _cmr_id, id: job_id} ->
        if InvoiceResolver.employee_verified?(%{job_id: job_id, user_id: current_user.id}) do
          case CashPaymentController.adjust_cash_payment(payment, input) do
            {:ok, data} -> {:ok, data}
            {:error, error} -> {:error, error}
          end
        else
          {:error, ["you are not permitted!"]}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_cash_payment(_, %{input: %{id: id} = input}, %{
        context: %{current_user: current_user}
      }) do
    input =
      Map.merge(input, %{
        country_id: current_user.country_id,
        user_id: current_user.id,
        user: current_user
      })

    payment =
      case input do
        %{paid_method_id: "cheque"} -> Jobs.get_job_by_cheque_payment_id(id)
        _ -> Jobs.get_job_by_cash_payment_id(id)
      end

    case payment do
      nil ->
        {:error, ["Invoice for this Job does not exists"]}

      %{inserted_by: cmr_id, id: _job_id} ->
        if cmr_id == current_user.id do
          case CashPaymentController.update_cash_payment(input) do
            {:ok, data} -> {:ok, data}
            {:error, error} -> {:error, error}
          end
        else
          {:error, ["you are not permitted!"]}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end
end
