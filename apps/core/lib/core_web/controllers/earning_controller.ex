defmodule CoreWeb.Controllers.EarningController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.{Accounts, BSP, CashPayments, Employees, Invoices, Payments, PaypalPayments}
  alias Core.PaypalPayments.SubscriptionHandler, as: Subscription
  alias CoreWeb.Controllers.HyperWalletPaymentController

  #  def get_tudo_earning(input) do
  #    input = case input do
  #      %{to: _} -> input
  #      %{from: _} -> input
  #      _ -> Map.merge(input, %{from: Timex.shift(Timex.beginning_of_day(DateTime.utc_now), days: -30)})
  #    end
  #    {:ok, Payments.list_payments()}
  #  end

  def get_tudo_earning do
    payments = Payments.list_payments()
    {:ok, payments}
  end

  def get_cmr_paid_payments(input) do
    input =
      case input do
        %{to: _} ->
          input

        %{from: _} ->
          input

        _ ->
          Map.merge(input, %{
            from: Timex.shift(Timex.beginning_of_day(DateTime.utc_now()), days: -30)
          })
      end

    payments = Payments.get_cmr_paid_payments(input) |> preload_invoice_job_and_cash_payment()

    case Payments.get_balance_by_cmr(input.user_id) do
      %{cmr_spent_amount: spent_amount} ->
        {:ok, %{payments: payments, total_paid_amount: spent_amount}}

      _ ->
        {:ok, %{payments: payments}}
    end
  end

  def get_bsp_earning(%{user_id: user_id, branch_id: branch_id} = input) do
    input =
      case input do
        %{to: _} ->
          input

        %{from: _} ->
          input

        _ ->
          Map.merge(input, %{
            from: Timex.shift(Timex.beginning_of_day(DateTime.utc_now()), days: -30)
          })
      end

    bus_id =
      case BSP.get_branch!(branch_id) do
        %{business_id: bus_id} -> bus_id
        _ -> nil
      end

    business_ids = Enum.map(BSP.get_business_by_user_id(user_id), & &1.id)

    if bus_id in business_ids or
         Employees.get_owner_or_manager_by_user_and_branch(user_id, branch_id) != nil do
      earnings =
        Payments.get_bsp_earnings(input)
        |> preload_invoice_job_and_cash_payment()

      #      transfers = get_bsp_transfers(input)
      transfers = Payments.get_bsp_transfers_by(input)

      case Payments.get_balance_by_branch(branch_id) do
        %{
          bsp_pending_balance: pending_balance,
          bsp_available_balance: available_balance,
          bsp_annual_earning: annual_earning,
          bsp_annual_transfer: annual_transfer,
          bsp_cash_earning: bsp_cash_earning,
          tudo_due_amount: tudo_due_amount
        } ->
          earning = %{
            bsp_earnings: earnings,
            annual_earning: annual_earning,
            available_funds: available_balance,
            tudo_reserve: pending_balance,
            annual_transfers: annual_transfer,
            bsp_tranfers: transfers,
            bsp_cash_earning: bsp_cash_earning,
            tudo_due_amount: tudo_due_amount
          }

          {:ok, earning}

        _ ->
          {:ok, %{bsp_earnings: earnings, bsp_tranfers: transfers}}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  def get_bsp_transfers(input) do
    case Payments.get_bsp_transfers_by(input) do
      transfers ->
        Enum.reduce(transfers, [], fn %{payout_id: token} = transfer, acc ->
          case HyperWalletPaymentController.get_hyper_wallet_payment(%{payment_token: token}) do
            {:ok, data} -> [Map.merge(transfer, data) | acc]
            _ -> acc
          end
        end)
    end
  end

  def preload_invoice_job_and_cash_payment(payments) do
    Enum.map(payments, fn payment ->
      case payment do
        %{payment_purpose: %{"invoice_id" => invoice_id}, payment_method_id: payment_method} =
            earning ->
          earning =
            case Invoices.get_invoice_and_job(invoice_id) do
              %{} = invoice_job_object -> Map.merge(earning, invoice_job_object)
              _ -> earning
            end

          case payment_method do
            "cash" ->
              case CashPayments.get_cash_payment_by_invoice(invoice_id) do
                [cash_payment] -> Map.merge(earning, %{cash_payment: cash_payment})
                _ -> earning
              end

            "cheque" ->
              case CashPayments.get_cheque_payment_by_invoice(invoice_id) do
                [cash_payment] -> Map.merge(earning, %{cash_payment: cash_payment})
                _ -> earning
              end

            _ ->
              earning
          end

        earning ->
          earning
      end
    end)
  end

  #  def preload_invoice_job_in_payment(earnings) do
  #    Enum.reduce(earnings, [], fn earning, acc ->
  #      case earning do
  #        %{payment_purpose: %{"invoice_id" => invoice_id}} ->
  #          case Invoices.get_invoice_and_job(invoice_id) do
  #            %{} = invoice_job_object ->
  #              [Map.merge(earning, invoice_job_object) | acc]
  #            _ -> [earning | acc]
  #          end
  #        earning -> [earning | acc]
  #      end
  #    end)
  #  end

  def get_bsp_paid_payments(%{user_id: user_id} = input) do
    if Accounts.get_bsp_user(user_id) != nil or
         Employees.get_owner_or_manager_by_user(user_id) != nil do
      payments = Payments.get_bsp_paid_payments(input)

      payments =
        Enum.map(payments, fn %{payment_purpose: purpose} = payment ->
          case purpose do
            %{"braintree_subscription_id" => sub_id} ->
              case Payments.get_brain_tree_subscription(sub_id) do
                %{} = sub -> Map.merge(payment, %{subscription: sub})
                _ -> payment
              end

            %{"paypal_subscription_id" => sub_id} ->
              case PaypalPayments.get_paypal_subscription(sub_id) do
                %{
                  paypal_subscription_id: paypal_subscription_id,
                  monthly_price: monthly_price,
                  annual_price: annual_price
                } = sub ->
                  sub =
                    case Subscription.get_paypal_subscription(paypal_subscription_id) do
                      {:ok,
                       %{
                         "billing_info" => %{
                           "next_billing_time" => next_billing,
                           "cycle_executions" => [cycle | _],
                           "last_payment" => %{"amount" => %{"value" => _}}
                         }
                       }} ->
                        price = if is_nil(monthly_price), do: annual_price, else: monthly_price

                        Map.merge(sub, %{
                          next_billing_period_date: extract_date(next_billing),
                          next_billing_period_amount: price,
                          current_billing_cycle: cycle["cycles_completed"]
                        })

                      _ ->
                        sub
                    end

                  Map.merge(payment, %{paypal_subscription: sub})

                _ ->
                  payment
              end

            %{"promotion_pricing_id" => promo_id} ->
              case Payments.get_promotion_purchase_price(promo_id) do
                %{} = pricing -> Map.merge(payment, %{promotion_pricing: pricing})
                _ -> payment
              end

            %{"subscription_feature_ids" => subscription_feature_ids} ->
              features =
                Enum.reduce(subscription_feature_ids, [], fn id, acc ->
                  case Payments.get_available_subscription_feature(id) do
                    %{} = feature -> acc ++ [feature]
                    _ -> acc
                  end
                end)

              Map.merge(payment, %{subscription_features: features})

            %{"cash_payment_id" => cash_payment_id} ->
              case CashPayments.get_cash_payment(cash_payment_id) do
                %{} = cash_payment -> Map.merge(payment, %{cash_payment: cash_payment})
                _ -> payment
              end

            _ ->
              payment
          end
        end)

      {:ok, payments}
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  defp extract_date(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, utc, 0} -> DateTime.to_date(utc)
      _ -> {:error, :invalid}
    end
  end
end
