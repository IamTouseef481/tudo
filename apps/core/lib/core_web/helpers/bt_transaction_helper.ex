defmodule CoreWeb.Helpers.BtTransactionHelper do
  #   Core.Payments.Sages.Transaction
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.Jobs.JobNotificationHandler
  alias Core.Payments
  alias Core.Payments.TipsDonationsBspAmountsCalculator, as: AMC
  alias CoreWeb.Utils.CommonFunctions
  alias CoreWeb.Helpers.{JobHelper, JobStatusesHelper}

  #
  # Main actions
  #
  def get_brain_tree_transaction(params) do
    new()
    |> run(:transaction, &get_transaction/2, &abort/3)
    |> run(:bt_transaction, &get_bt_transaction/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def get_brain_tree_transaction_by(params) do
    new()
    |> run(:wallet, &get_wallet/2, &abort/3)
    |> run(:bt_transactions, &get_bt_transaction_by/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_brain_tree_transaction(params) do
    new()
    |> run(:customer_validation, &customer_validation/2, &abort/3)
    |> run(:verify_item_amount, &verify_transaction_amount_with_purpose/2, &abort/3)
    |> run(:wallet, &get_wallet/2, &abort/3)
    |> run(:token, &get_payment_method_token/2, &abort/3)
    |> run(:nonce, &create_payment_method_nonce/2, &abort/3)
    |> run(:altered_params, &calculate_tips_and_donations/2, &abort/3)
    |> run(:update_job, &update_job_for_paid/2, &abort/3)
    |> run(:verfy_payable_amount, &verify_total_payable_amount/2, &abort/3)
    |> run(:bt_transaction, &create_braintree_transaction/2, &abort/3)
    |> run(:local_transaction, &create_local_transaction/2, &abort/3)
    |> run(:payment_available_for_bsp, &make_payment_available_for_bsp/2, &abort/3)
    |> run(:update_balance, &update_balance/2, &abort/3)
    |> run(:update_cmr_spent_amount, &update_cmr_spent_amount/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def refund_brain_tree_transaction(params) do
    new()
    |> run(:transaction, &get_transaction/2, &abort/3)
    |> run(:bt_transaction, &refund_bt_transaction/2, &abort/3)
    #    |> run(:local_transaction, &create_local_transaction/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------
  defp customer_validation(_, %{user: user, password: password}) do
    case Argon2.verify_pass(password, user.password_hash) do
      true -> {:ok, user}
      _ -> {:error, ["Invalid user password"]}
    end
  end

  defp customer_validation(_, %{user: user}) do
    {:ok, user}
  end

  defp verify_transaction_amount_with_purpose(_, params) do
    case AMC.verify_transaction_amount_with_purpose(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  defp get_wallet(_, params) do
    case Payments.get_brain_tree_wallet_by(params) do
      [] -> {:error, ["account doesn't exist"]}
      [data] -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch account"], __ENV__.line)
  end

  defp get_payment_method_token(%{wallet: customer}, params) do
    case params do
      %{token: token} ->
        params = Map.merge(params, %{customer_id: customer.id, token: token})

        case Payments.get_brain_tree_payment_method_by(params) do
          [] -> {:error, ["Payment method doesn't exist"]}
          [%{} = data] -> {:ok, data}
          [data | _] -> {:ok, data}
        end

      _ ->
        case Payments.get_brain_tree_default_payment_method_by_customer(customer.id) do
          [] -> {:error, ["Please select a payment method"]}
          [%{} = data] -> {:ok, data}
          [data | _] -> {:ok, data}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch Payment Method"], __ENV__.line)
  end

  defp create_payment_method_nonce(%{token: %{token: payment_method_token}}, _params) do
    case Braintree.PaymentMethodNonce.create(payment_method_token) do
      {:ok, nonce} ->
        {:ok, nonce}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree transaction"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Something went wrong, unable to create Payment Method Nonce"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch Payment Method Nonce"], __ENV__.line)
  end

  #  BSP side transaction flow
  defp calculate_tips_and_donations(
         _,
         %{promotion_pricing_id: _pricing_id, amount: _amount} = params
       ) do
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
      logger(__MODULE__, exception, ["Cannot add donations and Gratuity"], __ENV__.line)
  end

  defp calculate_tips_and_donations(_, params) do
    Map.merge(params, %{
      custom_fields: %{invoice_amount: params.amount, bsp_amount: params.amount}
    })
    |> AMC.add_other_tudo_charges(params.amount)
  end

  def create_braintree_transaction(
        %{nonce: %{nonce: nonce}, altered_params: %{amount: amount} = params},
        _
      ) do
    params =
      Map.drop(params, [
        :user_id,
        :branch_id,
        :type_id,
        :payment_method_id,
        :token,
        :password,
        :payable_amount,
        :user,
        :promotion_pricing_id,
        :job_id,
        :invoice_id,
        :country_id,
        :get_insured
      ])

    # brain tree accepts only upto 2 decimals,
    #    converted to string because in some cases BT returns error when amount is multiple of 100 like 1200
    amount = if is_float(amount), do: :erlang.float_to_binary(amount, decimals: 2), else: amount
    params = Map.merge(params, %{payment_method_nonce: nonce, amount: amount})

    case Braintree.Transaction.sale(params) do
      {:ok, transaction} ->
        transaction = Map.put(transaction, :amount, transaction.amount |> String.to_float())
        {:ok, convert_donations_in_map(transaction)}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree transaction"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["Something went wrong, Braintree Payment transaction failed!"],
          __ENV__.line
        )
    end
  end

  def create_braintree_transaction(_, _) do
    {:error, ["Amount params missing!"]}
  end

  def create_brain_tree_paypal_transaction(%{altered_params: %{amount: amount} = params}, _) do
    params =
      Map.drop(params, [
        :user_id,
        :branch_id,
        :type_id,
        :payment_method_id,
        :token,
        :password,
        :user,
        :promotion_pricing_id,
        :job_id,
        :invoice_id,
        :country_id,
        :get_insured
      ])

    amount = if is_float(amount), do: :erlang.float_to_binary(amount, decimals: 2), else: amount
    params = Map.merge(params, %{amount: amount})

    case Braintree.Transaction.sale(params) do
      {:ok, transaction} ->
        {:ok, convert_donations_in_map(transaction)}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree transaction"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Something went wrong, Braintree Paymnt transaction failed!"]}
    end
  end

  defp convert_donations_in_map(transaction) do
    case transaction do
      %{custom_fields: %{donations: donations}} ->
        donations =
          String.replace(donations, "=>", ":")
          |> CoreWeb.Utils.CommonFunctions.string_to_map()

        {_, transaction} =
          get_and_update_in(transaction.custom_fields.donations, &{&1, donations})

        transaction

      transaction ->
        transaction
    end
  end

  #  BSP transaction to Tudo
  defp create_local_transaction(
         %{bt_transaction: %{id: transaction_id}, altered_params: params} = effects,
         %{user_id: user_id, country_id: country_id, promotion_pricing_id: promotion_pricing_id} =
           _input_params
       ) do
    branch_id =
      case Payments.get_promotion_purchase_price(promotion_pricing_id) do
        %{branch_id: branch_id} -> branch_id
        _ -> nil
      end

    token =
      case effects do
        %{token: %{token: token}} -> token
        _ -> nil
      end

    %{payment_gateway_fee: payment_gateway_fee} =
      gateway_fee_params =
      AMC.get_tudo_payment_gateway_charges("braintree_fee", params.amount, country_id)

    tudo_amount = CommonFunctions.round_off_value(params.amount - payment_gateway_fee)

    params =
      Map.merge(params, gateway_fee_params)
      |> Map.merge(%{
        transaction_id: transaction_id,
        user_id: user_id,
        total_transaction_amount: params.amount,
        tudo_total_amount: tudo_amount,
        from_bsp: true,
        payment_method_token: token,
        branch_id: branch_id,
        payment_purpose: %{promotion_pricing_id: promotion_pricing_id},
        bsp_payment_status_id: "active",
        paid_at: DateTime.utc_now()
      })

    case Payments.create_payment(params) do
      {:ok, local_payment} ->
        {:ok, local_payment}

      {:error, _error} ->
        {:error, ["Something went wrong, unable to create transaction"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Cannot create local transaction"], __ENV__.line)
  end

  #  CMR transaction to Tudo having job id in params
  defp create_local_transaction(
         %{
           bt_transaction: %{id: transaction_id, currency_iso_code: currency},
           altered_params: params
         } = effects,
         input_params
       ) do
    currency_symbol =
      case Core.Regions.get_country_by_currency(currency) do
        [%{currency_symbol: symbol} | _] -> symbol
        _ -> ""
      end

    token =
      case effects do
        %{token: %{token: token}} -> token
        _ -> nil
      end

    input_params = Map.merge(input_params, %{currency_symbol: currency_symbol})

    case AMC.creates_local_transaction(token, transaction_id, input_params, params, "braintree") do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Cannot create local transaction"], __ENV__.line)
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

  defp make_payment_available_for_bsp(%{local_transaction: local_transaction}, %{
         promotion_pricing_id: _
       }) do
    case Payments.update_payment(local_transaction, %{bsp_payment_status_id: "active"}) do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  defp make_payment_available_for_bsp(%{local_transaction: local_transaction}, %{
         cash_payment_id: _
       }) do
    case Payments.update_payment(local_transaction, %{bsp_payment_status_id: "active"}) do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  defp make_payment_available_for_bsp(%{local_transaction: local_transaction}, %{
         subscription_feature_slug: _
       }) do
    case Payments.update_payment(local_transaction, %{bsp_payment_status_id: "active"}) do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  defp make_payment_available_for_bsp(
         %{local_transaction: local_transaction},
         %{
           country_id: country_id
         } = params
       ) do
    branch_id =
      case Core.BSP.get_branch_id_by_job_id(params[:job_id]) do
        %{id: id} -> id
        _ -> nil
      end

    {:ok, AMC.make_payment_available_for_bsp(local_transaction.id, country_id, branch_id)}
  end

  #  BSP side transaction flow to purchase something
  defp update_balance(
         %{
           local_transaction: %{
             tudo_total_amount: tudo_amount,
             branch_id: branch_id,
             total_transaction_amount: bsp_spent_amount
           }
         },
         %{user_id: _user_id, promotion_pricing_id: _promotion_pricing_id}
       ) do
    case Payments.get_balance_by_branch(branch_id) do
      nil ->
        attrs = %{
          tudo_balance: tudo_amount,
          branch_id: branch_id,
          bsp_spent_amount: bsp_spent_amount
        }

        case Payments.create_balance(attrs) do
          {:ok, balance} ->
            make_annual_amounts_zero_on_year_start(branch_id)
            {:ok, balance}

          {:error, _} ->
            {:error, ["error while creating balance"]}
        end

      %{tudo_balance: tudo_balance, bsp_spent_amount: current_bsp_spent_amount} = balance ->
        tudo_balance = CommonFunctions.round_off_value(tudo_balance + tudo_amount)

        bsp_spent_amount =
          CommonFunctions.round_off_value(current_bsp_spent_amount + bsp_spent_amount)

        case Payments.update_balance(balance, %{
               tudo_balance: tudo_balance,
               bsp_spent_amount: bsp_spent_amount
             }) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while updating balance"]}
        end

      _ ->
        {:error, ["error while getting balance"]}
    end
  end

  # CMR side transaction flow
  defp update_balance(%{local_transaction: local_transaction}, _params) do
    case update_balance_on_cmr_payment_with_check_of_chargebacks(local_transaction) do
      {:ok, balance} -> {:ok, balance}
      {:error, error} -> {:error, error}
    end
  end

  defp update_cmr_spent_amount(_, %{promotion_pricing_id: _}) do
    {:ok, ["no CMR expense"]}
  end

  defp update_cmr_spent_amount(%{local_transaction: %{total_transaction_amount: amount}}, %{
         user_id: user_id
       }) do
    case Payments.get_balance_by_cmr(user_id) do
      nil ->
        attrs = %{cmr_spent_amount: amount, user_id: user_id}

        case Payments.create_balance(attrs) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["Error while creating Consumer spent amount"]}
        end

      %{cmr_spent_amount: cmr_spent_amount} = balance ->
        cmr_spent_amount = CommonFunctions.round_off_value(cmr_spent_amount + amount)

        case Payments.update_balance(balance, %{cmr_spent_amount: cmr_spent_amount}) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["Error while updating Consumer spent amount"]}
        end

      _ ->
        {:error, ["Error while getting Consumer spent amount"]}
    end
  end

  defp update_job_for_paid(_, %{job_id: job_id, user_id: user_id}) do
    params = %{
      id: job_id,
      job_status_id: "paid",
      job_cmr_status_id: "paid",
      job_bsp_status_id: "paid",
      updated_by: user_id
    }

    with {:ok, _, %{job: data, is_job_exist: previous_job, rescheduling_statuses: params}} <-
           JobHelper.update_job(params),
         _ <- JobNotificationHandler.send_notification_for_update_job(previous_job, data, params),
         _ <-
           JobStatusesHelper.auto_finalize_job_after_payment(%{
             job_id: job_id,
             get_insured: params[:get_insured]
           }) do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp update_job_for_paid(_, _) do
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

  defp get_transaction(_, %{user_id: user_id, transaction_id: id}) do
    case Payments.get_payment_by(%{transaction_id: id, user_id: user_id}) do
      [] -> {:error, ["Transaction doesn't exist!"]}
      [transaction] -> {:ok, transaction}
      transactions -> {:ok, transactions}
    end
  end

  defp get_bt_transaction(_, %{transaction_id: id}) do
    case Braintree.Transaction.find(id) do
      {:ok, transaction} ->
        {:ok, transaction}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree transaction"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Something went wrong, unable to fetch Braintree transaction"]}
    end
  end

  @doc """
  get_bt_transaction_by/2
  Get braintree transaction by -> customer_id

  TODO - Add to from in params for Braintree.Search.perform() to get transactions between given dates
  """

  def get_bt_transaction_by(%{wallet: %{customer_id: customer_id}}, _params) do
    params = %{customer_id: %{is: customer_id}}

    case Braintree.Search.perform(params, "transactions", &Braintree.Transaction.new/1) do
      {:ok, transactions} ->
        {:ok, transactions}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree transaction"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Something went wrong, unable to fetch Braintree transaction"]}
    end
  end

  defp refund_bt_transaction(_, %{amount: amount, transaction_id: id} = _params) do
    case Braintree.Transaction.refund(id, %{amount: amount}) do
      {:ok, transaction} ->
        {:ok, transaction}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree transaction"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["failed to refund transaction!"]}
    end
  end

  def update_balance_on_cmr_payment_with_check_of_chargebacks(%{
        bsp_total_amount: bsp_amount,
        tudo_total_amount: tudo_amount,
        chargebacks: chargebacks,
        branch_id: branch_id
      }) do
    bsp_current_pending_amount = (bsp_amount - chargebacks) |> CommonFunctions.round_off_value()

    case Payments.get_balance_by_branch(branch_id) do
      nil ->
        attrs = %{
          bsp_pending_balance: bsp_amount,
          tudo_balance: tudo_amount,
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
        bsp_pending_balance: bsp_pending_balance,
        tudo_balance: tudo_balance,
        tudo_due_amount: tudo_due_amount
      } = balance ->
        %{pending: bsp_pending_balance, due: tudo_due_amount} =
          if bsp_current_pending_amount < 0 do
            tudo_due_amount = (tudo_due_amount - bsp_amount) |> CommonFunctions.round_off_value()
            %{pending: bsp_pending_balance, due: tudo_due_amount}
          else
            bsp_pending_balance =
              CommonFunctions.round_off_value(bsp_pending_balance + bsp_current_pending_amount)

            %{pending: bsp_pending_balance, due: tudo_due_amount - chargebacks}
          end

        tudo_balance = CommonFunctions.round_off_value(tudo_balance + tudo_amount)

        case Payments.update_balance(balance, %{
               bsp_pending_balance: bsp_pending_balance,
               tudo_balance: tudo_balance,
               tudo_due_amount: tudo_due_amount
             }) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while updating balance"]}
        end

      _ ->
        {:error, ["error while getting balance"]}
    end
  end
end
