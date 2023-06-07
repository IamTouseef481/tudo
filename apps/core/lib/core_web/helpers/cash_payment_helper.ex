defmodule CoreWeb.Helpers.CashPaymentHelper do
  #   Core.CashPayments.Sages.Cash
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{Accounts, BSP, CashPayments, Employees, Invoices, Jobs, Payments}
  alias Core.Jobs.JobNotificationHandler
  alias Core.Payments.TipsDonationsBspAmountsCalculator, as: AMC
  alias CoreWeb.GraphQL.Resolvers.InvoiceResolver
  alias CoreWeb.Helpers.{EmployeesHelper, JobHelper, JobStatusesHelper}

  def create_cash_payment(params) do
    new()
    |> run(:customer_validation, &customer_validation/2, &abort/3)
    |> run(:verify_item_amount, &verify_transaction_amount_with_purpose/2, &abort/3)
    |> run(:altered_params, &calculate_tips_and_donations/2, &abort/3)
    |> run(:verify_payable_amount, &verify_total_payable_amount/2, &abort/3)
    |> run(:cash_payment, &create_local_cash_payment/2, &abort/3)
    |> run(:local_transaction, &create_local_transaction/2, &abort/3)
    |> run(:cash_payment_socket, &cash_payment_socket/2, &abort/3)
    |> run(:cash_payment_notification, &cash_payment_notification_for_bsp/2, &abort/3)
    |> run(:update_job_for_pending_cash_payment, &update_job_for_pending_cash_payment/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def generate_cash_payment(params) do
    new()
    |> run(:cash_payment, &get_local_cash_payment/2, &abort/3)
    |> run(:get_local_transaction, &get_local_transaction/2, &abort/3)
    |> run(:verify_user_permission, &verify_user_for_generate_payment/2, &abort/3)
    #    |> run(:customer_validation, &customer_validation/2, &abort/3)
    #    |> run(:verify_item_amount, &verify_transaction_amount_with_purpose/2, &abort/3)
    #    |> run(:altered_params, &calculate_tips_and_donations/2, &abort/3)
    |> run(:update_job, &update_job_for_paid/2, &abort/3)
    #    |> run(:verify_payable_amount, &verify_total_payable_amount/2, &abort/3)
    |> run(:updated_cash_payment, &update_local_cash_payment/2, &abort/3)
    |> run(:local_transaction, &update_local_transaction/2, &abort/3)
    #    |> run(:local_transaction, &create_local_transaction/2, &abort/3)
    |> run(:update_balance, &update_balance/2, &abort/3)
    |> run(:update_cmr_spent_amount, &update_cmr_spent_amount/2, &abort/3)
    |> run(:cash_payment_notification, &cash_payment_notification_for_cmr/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  defp customer_validation(_, %{user: user, password: password}) do
    case Argon2.verify_pass(password, user.password_hash) do
      true -> {:ok, user}
      _ -> {:error, ["Invalid user password"]}
    end
  end

  defp customer_validation(_, _) do
    {:ok, ["valid"]}
  end

  defp verify_transaction_amount_with_purpose(_, params) do
    type = if Map.has_key?(params, :cheque_amount), do: "cheque", else: "cash"

    case AMC.verify_transaction_amount_with_purpose(Map.merge(params, %{payment_gateway: type})) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  #  BSP side transaction flow
  defp calculate_tips_and_donations(_, %{promotion_pricing_id: _pricing_id} = params) do
    {:ok, params}
  end

  defp calculate_tips_and_donations(_, %{custom_fields: _custom_fields, amount: _amount} = params) do
    case AMC.calculate_tips_and_donations(params) do
      {:ok, data} ->
        {:ok, data}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["Error in adding Donations and Gratuity!"]}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't add Donations and Gratuity!"],
        __ENV__.line
      )
  end

  defp calculate_tips_and_donations(_, params) do
    Map.merge(params, %{
      custom_fields: %{invoice_amount: params.amount, bsp_amount: params.amount}
    })
    |> AMC.add_other_tudo_charges(params.amount)
  end

  defp update_job_for_paid(%{get_local_transaction: %{insurance_amount: insurance_amount}}, %{
         job_id: job_id,
         user_id: user_id
       }) do
    case Jobs.get_job(job_id) do
      %{job_status_id: "paid"} ->
        {:ok, ["already paid"]}

      _ ->
        params = %{
          id: job_id,
          job_status_id: "paid",
          job_cmr_status_id: "paid",
          job_bsp_status_id: "paid",
          updated_by: user_id
        }

        insured = if insurance_amount > 0, do: true, else: false

        with {:ok, _, %{job: job, is_job_exist: previous_job, rescheduling_statuses: params}} <-
               JobHelper.update_job(params),
             _ <-
               JobNotificationHandler.send_notification_for_update_job(previous_job, job, params),
             _ <-
               JobStatusesHelper.auto_finalize_job_after_payment(%{
                 job_id: job_id,
                 get_insured: insured
               }) do
          {:ok, job}
        else
          {:error, error} -> {:error, error}
        end
    end
  end

  defp update_job_for_paid(_, _) do
    {:ok, ["no need to update job status"]}
  end

  defp update_job_for_pending_cash_payment(
         %{cash_payment: %{id: id}},
         %{job_id: job_id, user_id: user_id, employee_verified: true} = input
       ) do
    params = %{
      id: job_id,
      job_bsp_status_id: "payment_confirmation_pending",
      job_cmr_status_id: "payment_confirmation_pending",
      updated_by: user_id
    }

    with {:ok, _, _} <-
           JobHelper.update_job(params),
         {:ok, _last, %{updated_cash_payment: cash_payment, local_transaction: local_payment}} =
           generate_cash_payment(Map.merge(input, %{id: id})) do
      {:ok, Map.merge(cash_payment, %{payment_details: local_payment})}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp update_job_for_pending_cash_payment(_, %{job_id: job_id, user_id: user_id}) do
    params = %{
      id: job_id,
      job_bsp_status_id: "payment_confirmation_pending",
      job_cmr_status_id: "payment_confirmation_pending",
      updated_by: user_id
    }

    with {:ok, _, %{job: job, is_job_exist: previous_job, rescheduling_statuses: params}} <-
           JobHelper.update_job(params),
         _ <- JobNotificationHandler.send_notification_for_update_job(previous_job, job, params) do
      {:ok, job}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp update_job_for_pending_cash_payment(_, _) do
    {:ok, ["no need to update job status"]}
  end

  defp verify_total_payable_amount(%{altered_params: %{amount: calculated_amount}}, %{
         payable_amount: payable_amount
       }) do
    case AMC.verify_total_payable_amount(calculated_amount, payable_amount) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  defp verify_total_payable_amount(_, _) do
    {:ok, ["valid"]}
  end

  defp get_local_cash_payment(_, %{id: id, payment_method_id: "cash"}) do
    case CashPayments.get_cash_payment(id) do
      %{adjust: true} = data -> {:ok, data}
      %{adjust: false} -> {:error, ["Cash Payment locked, you can not update cash payment"]}
      _ -> {:error, ["Cash Payment does not exist"]}
    end
  end

  defp get_local_cash_payment(_, %{id: id, payment_method_id: "cheque"}) do
    case CashPayments.get_cheque_payment(id) do
      %{adjust: true} = data -> {:ok, data}
      %{adjust: false} -> {:error, ["Cheque Payment locked, you can not update cheque payment"]}
      _ -> {:error, ["Cheque Payment does not exist"]}
    end
  end

  defp get_local_cash_payment(_, %{id: _id, payment_method_id: _}) do
    {:error, ["Unknown Payment method selected"]}
  end

  defp get_local_transaction(%{cash_payment: %{invoice_id: invoice_id}}, %{id: _id}) do
    case Payments.get_payment_by_invoice_id(invoice_id) do
      %{} = data -> {:ok, data}
      _ -> {:error, ["Local Transaction does not exist"]}
    end
  end

  defp verify_user_for_generate_payment(%{cash_payment: %{invoice_id: invoice_id}}, %{
         user_id: user_id
       }) do
    case Jobs.get_job_by_invoice(invoice_id) do
      nil ->
        {:error, ["Invoice for this Job does not exists"]}

      %{inserted_by: _cmr_id, id: job_id} ->
        if InvoiceResolver.employee_verified?(%{job_id: job_id, user_id: user_id}) do
          {:ok, ["valid"]}
        else
          {:error, ["you are not permitted!"]}
        end
    end
  end

  #  for cash flow
  defp create_local_cash_payment(
         %{altered_params: %{amount: payable_amount}},
         %{paid_amount: paid_amount} = params
       ) do
    if paid_amount < payable_amount do
      {:error, ["Due amount is more than you are paying"]}
    else
      params = %{
        pay_due_amount: payable_amount,
        paid_amount: paid_amount,
        returned_amount: paid_amount - payable_amount,
        invoice_id: params[:invoice_id],
        adjust: true
      }

      case CashPayments.create_cash_payment(params) do
        {:ok, data} -> {:ok, data}
        {:error, error} -> {:error, error}
      end
    end
  end

  #  for cheque flow
  defp create_local_cash_payment(
         %{altered_params: %{amount: payable_amount}},
         %{cheque_amount: paid_amount} = params
       ) do
    if paid_amount < payable_amount do
      {:error, ["Due amount is more than you are paying"]}
    else
      params = Map.merge(params, %{pay_due_amount: payable_amount, adjust: true})

      case CashPayments.create_cheque_payment(params) do
        {:ok, data} -> {:ok, data}
        {:error, error} -> {:error, error}
      end
    end
  end

  def cash_payment_socket(
        %{
          cash_payment: %{invoice_id: invoice_id} = cash_payment,
          local_transaction: local_payment
        },
        _params
      ) do
    branch_id =
      with %{job_id: job_id} <- Invoices.get_invoice(invoice_id),
           %{id: branch_id} <- BSP.get_branch_by_job_id(job_id) do
        branch_id
      else
        _ -> nil
      end

    cash_payment =
      Map.merge(cash_payment, %{payment_details: local_payment})
      |> EmployeesHelper.remove_structs_from_data()

    CoreWeb.Endpoint.broadcast("cash_payment:branch_id:#{branch_id}", "cash_payment", %{
      cash_payment: cash_payment
    })

    {:ok, ["sent"]}
  end

  def cash_payment_notification_for_bsp(
        %{
          cash_payment: %{invoice_id: invoice_id, pay_due_amount: pay_due_amount} = cp,
          local_transaction: %{id: payment_id, currency_symbol: currency_symbol}
        },
        params
      ) do
    [service_type_id, job_id, employee_id, cmr_id] =
      case Jobs.get_job_by_invoice(invoice_id) do
        %{
          service_type_id: service_type_id,
          id: job_id,
          employee_id: employee_id,
          inserted_by: cmr_id
        } ->
          [service_type_id, job_id, employee_id, cmr_id]

        _ ->
          [nil, nil, nil, nil]
      end

    {purpose, params} =
      if Map.has_key?(params, :cheque_amount) do
        {"cheque_payment_for_bsp", %{cheque_number: cp.cheque_number}}
      else
        {"cash_payment_for_bsp", %{}}
      end

    cmr_profile_name =
      case Accounts.get_user!(cmr_id) do
        %{profile: %{"first_name" => first_name, "last_name" => last_name}} ->
          first_name <> " " <> last_name

        _ ->
          ""
      end

    if is_nil(employee_id) do
      {:ok, ["notification not sent"]}
    else
      %{user_id: owner_user_id} = BSP.get_business_by_employee_id(employee_id)
      %{user_id: employee_user_id, branch_id: branch_id} = Employees.get_employee(employee_id)
      #      currency is missing in params for notification
      params =
        Map.merge(params, %{
          service_type: service_type_id,
          job_id: job_id,
          branch_id: branch_id,
          payment_id: payment_id,
          cmr_profile_name: cmr_profile_name,
          settlement_amount: pay_due_amount,
          currency: currency_symbol
        })

      if employee_user_id == owner_user_id do
        Core.Jobs.JobNotificationHandler.sends_notification(
          employee_user_id,
          "bsp",
          params,
          purpose
        )
      else
        Core.Jobs.JobNotificationHandler.sends_notification(owner_user_id, "bsp", params, purpose)

        Core.Jobs.JobNotificationHandler.sends_notification(
          employee_user_id,
          "bsp",
          params,
          purpose
        )
      end

      {:ok, ["notification sent"]}
    end
  end

  def cash_payment_notification_for_cmr(
        %{
          updated_cash_payment: %{invoice_id: invoice_id, pay_due_amount: pay_due_amount} = cp,
          local_transaction: %{id: payment_id}
        },
        params
      ) do
    [service_type_id, job_id, cmr_id] =
      case Jobs.get_job_by_invoice(invoice_id) do
        %{service_type_id: service_type_id, id: job_id, inserted_by: cmr_id} ->
          [service_type_id, job_id, cmr_id]

        _ ->
          [nil, nil, nil]
      end

    {purpose, params} =
      if Map.has_key?(params, :cheque_amount) do
        {"cheque_payment_for_cmr", %{cheque_number: cp.cheque_number}}
      else
        {"cash_payment_for_cmr", %{}}
      end

    if is_nil(cmr_id) do
      {:ok, ["notification not sent"]}
    else
      #      currency is missing in params for notification
      params =
        Map.merge(params, %{
          service_type: service_type_id,
          job_id: job_id,
          payment_id: payment_id,
          settlement_amount: pay_due_amount
        })

      Core.Jobs.JobNotificationHandler.sends_notification(cmr_id, "cmr", params, purpose)
      {:ok, ["notification sent"]}
    end
  end

  defp update_local_cash_payment(
         %{
           cash_payment: cash_payment,
           get_local_transaction: %{
             tudo_total_deducted_amount: tudo_due_amount,
             total_transaction_amount: pay_due_amount
           }
         },
         %{paid_amount: paid_amount, payment_method_id: "cash"} = params
       ) do
    returned_amount =
      case params do
        %{returned_amount: returned_amount} -> returned_amount
        _ -> paid_amount - pay_due_amount
      end

    params = %{
      pay_due_amount: pay_due_amount,
      paid_amount: paid_amount,
      returned_amount: returned_amount,
      adjust: false,
      tudo_due_amount: tudo_due_amount
    }

    case CashPayments.update_cash_payment(cash_payment, params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  defp update_local_cash_payment(
         %{
           cash_payment: cash_payment,
           get_local_transaction: %{
             tudo_total_amount: tudo_amount,
             chargebacks: chargebacks,
             donation_amount: donation_amount,
             total_transaction_amount: pay_due_amount,
             govt_fee: govt_fee
           }
         },
         %{payment_method_id: "cheque"} = params
       ) do
    tudo_due_amount = tudo_amount + chargebacks + govt_fee + donation_amount

    params =
      Map.merge(params, %{
        pay_due_amount: pay_due_amount,
        adjust: false,
        tudo_due_amount: tudo_due_amount
      })

    case CashPayments.update_cheque_payment(cash_payment, params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  defp update_local_transaction(%{get_local_transaction: transaction}, _params) do
    params = %{
      cmr_payment_status_id: "active",
      bsp_payment_status_id: "active",
      paid_at: DateTime.utc_now()
    }

    case Payments.update_payment(transaction, params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  defp create_local_transaction(
         %{altered_params: params},
         %{user_id: user_id, country_id: _country_id, promotion_pricing_id: promotion_pricing_id} =
           _input_params
       ) do
    branch_id =
      case Payments.get_promotion_purchase_price(promotion_pricing_id) do
        %{branch_id: branch_id} -> branch_id
        _ -> nil
      end

    params =
      Map.merge(
        params,
        %{
          user_id: user_id,
          total_transaction_amount: params.amount,
          tudo_total_amount: params.amount,
          from_bsp: true,
          branch_id: branch_id,
          bsp_payment_status_id: "active",
          payment_purpose: %{promotion_pricing_id: promotion_pricing_id},
          paid_at: DateTime.utc_now(),
          transaction_id: "#{DateTime.to_unix(DateTime.utc_now(), :nanosecond)}"
        }
      )

    case Payments.create_payment(params) do
      {:ok, local_payment} ->
        {:ok, local_payment}

      {:error, _} ->
        {:error, ["Something went wrong, unable to create transaction"]}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't create local transaction"],
        __ENV__.line
      )
  end

  #  CMR transaction to BSP having job id in params
  defp create_local_transaction(
         %{altered_params: params},
         %{country_id: country_id} = input_params
       ) do
    currency_symbol =
      case Core.Regions.get_countries(country_id) do
        %{currency_symbol: currency_symbol} -> currency_symbol
        _ -> "$"
      end

    input_params = Map.merge(input_params, %{currency_symbol: currency_symbol})
    transaction_id = "#{DateTime.to_unix(DateTime.utc_now(), :nanosecond)}"
    type = if Map.has_key?(input_params, :cheque_amount), do: "cheque", else: "cash"

    case AMC.creates_local_transaction(nil, transaction_id, input_params, params, type) do
      {:ok, data} ->
        {:ok, data}

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't create local transaction"],
        __ENV__.line
      )
  end

  #  BSP side transaction flow to purchase something
  #  defp update_balance(%{local_transaction: %{tudo_total_amount: tudo_amount, branch_id: branch_id,
  #    total_transaction_amount: bsp_spent_amount}}, %{promotion_pricing_id: _promotion_pricing_id}) do
  #    case Payments.get_balance_by_branch(branch_id) do
  #      nil ->
  #        attrs = %{tudo_balance: tudo_amount, branch_id: branch_id, bsp_spent_amount: bsp_spent_amount}
  #        case Payments.create_balance(attrs) do
  #          {:ok, balance} ->
  #            make_annual_amounts_zero_on_year_start(branch_id)
  #            {:ok, balance}
  #          {:error, _} -> {:error, ["error while creating balance"]}
  #        end
  #      %{tudo_balance: tudo_balance, bsp_spent_amount: current_bsp_spent_amount} = balance ->
  #        tudo_balance = round_off_value(tudo_balance + tudo_amount)
  #        bsp_spent_amount = round_off_value(current_bsp_spent_amount + bsp_spent_amount)
  #        case Payments.update_balance(balance, %{tudo_balance: tudo_balance, bsp_spent_amount: bsp_spent_amount}) do
  #          {:ok, balance} -> {:ok, balance}
  #          {:error, _} -> {:error, ["error while updating balance"]}
  #        end
  #      _ -> {:error, ["error while getting balance"]}
  #    end
  #  end

  # CMR side transaction flow
  #  do not call it if already updated balance, like payment cmr and bsp status is active means balance also updated earlier
  defp update_balance(
         %{
           updated_cash_payment: %{tudo_due_amount: tudo_due_amount},
           local_transaction: %{
             bsp_total_amount: bsp_amount,
             tudo_total_amount: tudo_amount,
             branch_id: branch_id
           }
         },
         _params
       ) do
    case Payments.get_balance_by_branch(branch_id) do
      nil ->
        attrs = %{
          bsp_total_earning: bsp_amount,
          bsp_annual_earning: bsp_amount,
          bsp_cash_earning: bsp_amount,
          tudo_balance: tudo_amount,
          tudo_due_amount: tudo_due_amount,
          branch_id: branch_id
        }

        case Payments.create_balance(attrs) do
          {:ok, balance} ->
            make_annual_amounts_zero_on_year_start(branch_id)
            {:ok, balance}

          {:error, _} ->
            {:error, ["error while creating balance"]}
        end

      %{
        bsp_cash_earning: bsp_cash_earning,
        tudo_balance: tudo_balance,
        bsp_total_earning: bsp_total_earning,
        bsp_annual_earning: bsp_annual_earning,
        tudo_due_amount: tudo_due_balance,
        bsp_available_balance: bsp_available_balance
      } = balance ->
        bsp_cash_earning = round_off_value(bsp_cash_earning + bsp_amount)
        tudo_balance = round_off_value(tudo_balance + tudo_amount)
        bsp_total_earning = round_off_value(bsp_total_earning + bsp_amount)
        bsp_annual_earning = round_off_value(bsp_annual_earning + bsp_amount)

        bsp_available_balance =
          (bsp_available_balance - (tudo_due_balance + tudo_due_amount))
          |> round_off_value()

        [bsp_available_balance, tudo_due_balance] =
          if bsp_available_balance >= 0 do
            [bsp_available_balance, 0]
          else
            [0, -bsp_available_balance]
          end

        case Payments.update_balance(balance, %{
               bsp_annual_earning: bsp_annual_earning,
               bsp_cash_earning: bsp_cash_earning,
               bsp_total_earning: bsp_total_earning,
               tudo_balance: tudo_balance,
               tudo_due_amount: tudo_due_balance,
               bsp_available_balance: bsp_available_balance
             }) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while updating balance"]}
        end

      _ ->
        {:error, ["error while getting balance"]}
    end
  end

  defp update_cmr_spent_amount(
         %{local_transaction: %{total_transaction_amount: amount, user_id: user_id}},
         %{invoice_id: _}
       ) do
    case Payments.get_balance_by_cmr(user_id) do
      nil ->
        attrs = %{cmr_spent_amount: amount, user_id: user_id}

        case Payments.create_balance(attrs) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["Error while creating Consumer spent amount"]}
        end

      %{cmr_spent_amount: cmr_spent_amount} = balance ->
        cmr_spent_amount = round_off_value(cmr_spent_amount + amount)

        case Payments.update_balance(balance, %{cmr_spent_amount: cmr_spent_amount}) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["Error while updating Consumer spent amount"]}
        end

      _ ->
        {:error, ["Error while getting Consumer spent amount"]}
    end
  end

  defp update_cmr_spent_amount(_, _) do
    {:ok, ["no CMR expense"]}
  end

  def make_annual_amounts_zero_on_year_start(branch_id) do
    time =
      DateTime.utc_now()
      |> CoreWeb.Utils.DateTimeFunctions.convert_utc_time_to_local_time()
      |> Timex.beginning_of_year()
      |> Timex.shift(years: 1)

    #    for testing
    #    time = Timex.shift(DateTime.utc_now, seconds: 10)
    Exq.enqueue_at(
      Exq,
      "default",
      time,
      "CoreWeb.Workers.AnnualBalanceUpdateWorker",
      [branch_id]
    )
  end
end
