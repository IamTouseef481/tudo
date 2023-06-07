defmodule CoreWeb.Workers.PaymentStatusUpdateWorker do
  @moduledoc false
  import CoreWeb.Utils.{Errors, CommonFunctions}
  alias Core.Payments

  def perform(payment_id, status) do
    logger(__MODULE__, payment_id, :info, __ENV__.line)

    case Core.Payments.get_payment(payment_id) do
      nil ->
        {:ok, ["no payment to be updated!"]}

      %{
        tudo_reserve_amount: current_earning,
        branch_id: branch_id,
        bsp_total_amount: bsp_total_earning
      } = payment ->
        case Core.Payments.update_payment(payment, %{bsp_payment_status_id: status}) do
          {:ok, data} ->
            update_balance(status, branch_id, current_earning, bsp_total_earning)
            {:ok, data}

          all ->
            all
        end
    end
  end

  # add this amount to available balance and bsp total balance and remove from pending balance
  defp update_balance(status, branch_id, current_earning, total_earning) do
    if status == "active" do
      case Payments.get_balance_by_branch(branch_id) do
        %{
          bsp_pending_balance: bsp_pending_balance,
          bsp_available_balance: bsp_available_balance,
          bsp_total_earning: bsp_total_earning,
          bsp_annual_earning: bsp_annual_earning
        } = balance ->
          bsp_pending_balance = round_off_value(bsp_pending_balance - current_earning)

          bsp_available_balance = round_off_value(bsp_available_balance + current_earning)

          bsp_total_earning = round_off_value(bsp_total_earning + total_earning)
          bsp_annual_earning = round_off_value(bsp_annual_earning + total_earning)

          params = %{
            bsp_pending_balance: bsp_pending_balance,
            bsp_available_balance: bsp_available_balance,
            bsp_total_earning: bsp_total_earning,
            bsp_annual_earning: bsp_annual_earning
          }

          case Payments.update_balance(balance, params) do
            {:ok, balance} -> {:ok, balance}
            {:error, _} -> {:error, ["error while updating balance"]}
          end

        _ ->
          {:error, ["error while getting balance"]}
      end
    else
      {:ok, ["status is #{status}"]}
    end
  end

  #  also checking tudo_due_amount
  #  defp update_balance(status, branch_id, deducted_amount, current_earning, current_chargebacks) do
  #    if status == "active" do
  #      case Payments.get_balance_by_branch(branch_id) do
  #        %{bsp_pending_balance: bsp_pending_balance, bsp_available_balance: bsp_available_balance,
  #          bsp_total_earning: bsp_total_earning, bsp_annual_earning: bsp_annual_earning,
  #          tudo_due_amount: chargebacks} = balance ->
  #
  #          bsp_pending_balance = round_off_value(bsp_pending_balance - current_earning)
  #          bsp_available_balance = round_off_value(bsp_available_balance + deducted_amount)
  #          bsp_total_earning = round_off_value(bsp_total_earning + current_earning)
  #          bsp_annual_earning = round_off_value(bsp_annual_earning + current_earning)
  #          chargebacks = round_off_value(chargebacks - current_chargebacks)
  #          params = %{bsp_pending_balance: bsp_pending_balance, bsp_available_balance: bsp_available_balance,
  #            bsp_total_earning: bsp_total_earning, bsp_annual_earning: bsp_annual_earning,
  #            tudo_due_amount: chargebacks}
  #          case Payments.update_balance(balance, params) do
  #            {:ok, balance} -> {:ok, balance}
  #            {:error, _} -> {:error, ["error while updating balance"]}
  #          end
  #        _ -> {:error, ["error while getting balance"]}
  #      end
  #    else
  #      {:ok, ["status is #{status}"]}
  #    end
  #  end
end
