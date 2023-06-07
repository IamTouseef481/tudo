defmodule CoreWeb.Helpers.BtSubscriptionHelper do
  #   Core.Payments.Sages.Subscription
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{Accounts, BSP, Payments}
  alias Core.Payments.TipsDonationsBspAmountsCalculator
  alias CoreWeb.Utils.CommonFunctions

  #
  # Main actions

  def get_brain_tree_subscription(params) do
    new()
    |> run(:subscription, &get_subscription/2, &abort/3)
    |> run(:bt_subscription, &get_bt_subscription/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def get_brain_tree_subscription_by(params) do
    new()
    #    |> run(:subscription, &get_subscription/2, &abort/3)
    |> run(:bt_subscriptions, &get_bt_subscriptions_by/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_brain_tree_subscription(params) do
    new()
    |> run(:customer_validation, &customer_validation/2, &abort/3)
    |> run(:is_subscription_exists, &is_subscription_exists/2, &abort/3)
    |> run(:foreign_keys_validity, &foreign_keys_validity/2, &abort/3)
    |> run(:wallet, &get_wallet/2, &abort/3)
    |> run(:token, &get_payment_method_token/2, &abort/3)
    #    |> run(:nonce, &create_payment_method_nonce/2, &abort/3)
    #    |> run(:altered_params, &calculate_tips_and_donations/2, &abort/3)
    |> run(:create_available_promotions, &create_available_promotions/2, &abort/3)
    |> run(:create_payment, &create_local_payment/2, &abort/3)
    |> run(:update_balance, &update_balance/2, &abort/3)
    |> run(:bt_subscription, &create_braintree_subscription/2, &abort/3)
    |> run(:local_subscription, &create_local_subscription/2, &abort/3)
    |> run(:update_payment, &update_local_payment/2, &abort/3)
    |> run(
      :payment_validation_billing_cycle,
      &payment_validation_on_each_billing_cycle/2,
      &abort/3
    )
    |> transaction(Core.Repo, params)
  end

  def retry_charge_brain_tree_subscription(params) do
    new()
    |> run(:subscription, &get_subscription/2, &abort/3)
    |> run(:bt_subscription, &retry_subscription/2, &abort/3)
    |> run(:local_subscription, &update_local_subscription/2, &abort/3)
    |> run(:create_payment, &create_local_payment/2, &abort/3)
    |> run(:update_payment, &update_local_payment/2, &abort/3)
    |> run(:update_payment_price, &update_local_payment_price/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_brain_tree_subscription(params) do
    new()
    |> run(:subscription, &get_subscription/2, &abort/3)
    |> run(:bt_subscription, &update_bt_subscription/2, &abort/3)
    |> run(:local_subscription, &update_local_subscription/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def cancel_brain_tree_subscription(params) do
    new()
    |> run(:subscription, &get_subscription/2, &abort/3)
    |> run(:bt_subscription, &cancel_bt_subscription/2, &abort/3)
    |> run(:local_subscription, &update_local_subscription/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------
  defp customer_validation(_, %{user: user, password: password}) do
    case Argon2.verify_pass(password, user.password_hash) do
      true -> {:ok, user}
      _ -> {:error, ["Invalid User and/ or Password"]}
    end
  end

  defp customer_validation(_, %{user: user}) do
    {:ok, user}
  end

  defp is_subscription_exists(_, %{business_id: id}) do
    case Payments.get_brain_tree_subscription_by_business(id) do
      [] ->
        {:ok, ["valid"]}

      [%{subscription_bsp_rule_id: id}] ->
        %{package_id: package} = Payments.get_subscription_bsp_rule(id)
        {:error, ["Your business already purchased the Package: #{package}"]}

      _subscriptions ->
        {:error, ["Your Business already enrolled for this Subscription package"]}
    end
  end

  defp get_subscription(_, %{user_id: user_id, business_id: bus_id}) do
    case Payments.get_brain_tree_subscription_by_user_and_business(user_id, bus_id) do
      [] -> {:error, ["Subscription package doesn't exist!"]}
      [subscription] -> {:ok, subscription}
      _subscriptions -> {:error, ["More than one Subscription"]}
    end
  end

  def retry_subscription(%{subscription: %{subscription_id: subscription_id}}, _params) do
    #    params = Map.drop(params, [:user_id, :branch_id, :business_id, :token, :password,])
    case Braintree.Subscription.retry_charge(subscription_id) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Subscription"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Error while retrying charge Braintree Subscription!"]}
    end
  end

  def foreign_keys_validity(_, parameters) do
    with {:ok, _data} <- get_subscription_bsp_rule(parameters),
         {:ok, _data} <- get_subscription_cmr_rule(parameters),
         {:ok, _data} <- get_subscription_status(parameters),
         {:ok, _data} <- get_user(parameters),
         {:ok, _data} <- get_business(parameters) do
      {:ok, parameters}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["unexpected error!"]}
    end
  end

  defp get_subscription_bsp_rule(%{subscription_bsp_rule_id: subscription_bsp_rule_id}) do
    case Payments.get_subscription_bsp_rule(subscription_bsp_rule_id) do
      nil -> {:error, ["This Service Provider Subscription rule doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  defp get_subscription_bsp_rule(_params) do
    {:ok, ["valid"]}
  end

  defp get_subscription_cmr_rule(%{subscription_cmr_rule_id: subscription_cmr_rule_id}) do
    case Payments.get_subscription_cmr_rule(subscription_cmr_rule_id) do
      nil -> {:error, ["This Consumer Subscription rule doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  defp get_subscription_cmr_rule(_params) do
    {:ok, ["valid"]}
  end

  defp get_subscription_status(%{status_id: status}) do
    case Payments.get_brain_tree_subscription_statuses(status) do
      nil -> {:error, ["This Braintree Subscription status doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  defp get_subscription_status(_params) do
    {:ok, ["valid"]}
  end

  defp get_user(%{user_id: user_id}) do
    case Accounts.get_user!(user_id) do
      nil -> {:error, ["this user doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  defp get_business(%{business_id: business_id}) do
    case BSP.get_business(business_id) do
      nil -> {:error, ["this business doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  defp get_wallet(_, %{payment_method_nonce: _nonce} = _params) do
    {:ok, ["no need to get wallet!"]}
  end

  defp get_wallet(_, params) do
    case Payments.get_brain_tree_wallet_by(params) do
      [] -> {:error, ["Braintree account doesn't exist"]}
      [data] -> {:ok, data}
    end
  rescue
    _ -> {:error, ["Unable to fetch Braintree Payment Gateway account"]}
  end

  defp get_payment_method_token(_, %{payment_method_nonce: _nonce} = _params) do
    {:ok, ["no need to fetch payment method!"]}
  end

  defp get_payment_method_token(%{wallet: %{id: id} = _customer}, params) do
    case params do
      %{payment_method_token: token} ->
        params = Map.merge(params, %{customer_id: id, token: token})

        case Payments.get_brain_tree_payment_method_by(params) do
          [] -> {:error, ["Payment method doesn't exist"]}
          [%{} = data] -> {:ok, data}
          [data | _] -> {:ok, data}
        end

      _ ->
        case Payments.get_brain_tree_default_payment_method_by_customer(id) do
          [] -> {:error, ["Please select a payment method"]}
          [%{} = data] -> {:ok, data}
          [data | _] -> {:ok, data}
        end
    end
  rescue
    _ -> {:error, ["Unable to fetch Payment method"]}
  end

  defp create_available_promotions(_, %{
         business_id: business_id,
         plan_id: rule,
         country_id: country_id
       }) do
    case Payments.get_subscription_bsp_rule_by_package_and_country(rule, country_id) do
      [] ->
        {:error, ["Subscription rule/ plan does not exist for this Country"]}

      [%{promotions: promotions}] ->
        if promotions == 0 do
          {:ok, ["You exceeded Promotion limit on your Subscription package"]}
        else
          list = Enum.to_list(1..promotions)

          promotions =
            Enum.reduce(list, [], fn _counter, acc ->
              case TipsDonationsBspAmountsCalculator.create_available_promotion(%{
                     additional: false,
                     broad_cast_range: 30,
                     business_id: business_id,
                     rule: rule,
                     price: nil,
                     country_id: country_id
                   }) do
                {:ok, data} -> [data | acc]
                {:error, _error} -> acc
              end
            end)

          {:ok, promotions}
        end

      _rules ->
        {:error, ["Multiple subscription rules against your Country and Subscription package"]}
    end
  end

  def create_braintree_subscription(%{token: %{token: token}}, %{options: opts} = params) do
    params =
      Map.drop(params, [
        :user_id,
        :branch_id,
        :business_id,
        :type_id,
        :token,
        :password,
        :user,
        :country_id
      ])

    case Braintree.Subscription.create(Map.merge(params, %{payment_method_token: token}), [opts]) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Subscription"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Something went wrong, Braintree Subscription failed!"]}
    end
  end

  def create_braintree_subscription(%{token: %{token: token}}, params) do
    params =
      Map.drop(params, [
        :user_id,
        :branch_id,
        :business_id,
        :type_id,
        :token,
        :password,
        :user,
        :country_id,
        :payment_method_id
      ])

    params =
      case params do
        %{first_billing_date: date} ->
          Map.merge(params, %{first_billing_date: Date.to_string(date)})

        params ->
          params
      end

    case Braintree.Subscription.create(Map.merge(params, %{payment_method_token: token})) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Subscription"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Something went wrong, Braintree Subscription failed!"]}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong while creating Braintree Subscription"],
        __ENV__.line
      )
  end

  defp create_local_subscription(
         %{
           bt_subscription:
             %{
               id: sub_id,
               status: status,
               status_history: [%{"currency_iso_code" => currency} | _]
             } = _sub
         },
         %{plan_id: plan, country_id: country_id} = params
       ) do
    currency_symbol =
      case Core.Regions.get_country_by_currency(currency) do
        [%{currency_symbol: symbol} | _] -> symbol
        _ -> ""
      end

    case Payments.get_subscription_bsp_rule_by_package_and_country(plan, country_id) do
      [] ->
        {:error, ["Subscription plan does not exist for this Country"]}

      [%{id: rule_id, package_validity: months}] ->
        params =
          case params do
            %{first_billing_date: fbd} ->
              end_date =
                if months == "unlimited" do
                  nil
                else
                  Timex.shift(fbd, months: String.to_integer(months))
                end

              Map.merge(params, %{
                start_date: fbd,
                expiry_date: end_date,
                subscription_id: sub_id,
                status_id: String.downcase(status),
                subscription_bsp_rule_id: rule_id
              })

            params ->
              end_date =
                if months == "unlimited" do
                  nil
                else
                  Timex.shift(Date.utc_today(), months: String.to_integer(months))
                end

              Map.merge(params, %{
                start_date: Date.utc_today(),
                expiry_date: end_date,
                subscription_id: sub_id,
                status_id: String.downcase(status),
                subscription_bsp_rule_id: rule_id,
                currency_symbol: currency_symbol
              })
          end

        case Payments.create_brain_tree_subscription(params) do
          {:ok, data} ->
            {:ok, data}

          {:error, _} ->
            {:error, ["unable to create local subscription"]}
        end

      _rules ->
        {:error, ["Multiple subscription rules against your Country and Subscription package"]}
    end
  end

  defp create_local_payment(
         %{token: %{token: token}},
         %{business_id: business_id, country_id: country_id} = input_params
       ) do
    price =
      case input_params do
        %{price: price} ->
          price

        %{plan_id: plan_id} ->
          case Payments.get_subscription_bsp_rule_by_package_and_country(plan_id, country_id) do
            [rule] ->
              case String.to_integer(rule.package_validity) do
                1 ->
                  rule.package_monthly_price

                12 ->
                  rule.package_annual_price

                months ->
                  rule.package_monthly_price * months
              end

            _ ->
              nil
          end
      end

    currency_symbol =
      case Core.Regions.get_countries(country_id) do
        %{currency_symbol: currency_symbol} -> currency_symbol
        _ -> "$"
      end

    %{payment_gateway_fee: payment_gateway_fee} =
      gateway_fee_params =
      TipsDonationsBspAmountsCalculator.get_tudo_payment_gateway_charges(
        "braintree_fee",
        price,
        country_id
      )

    tudo_amount = CommonFunctions.round_off_value(price - payment_gateway_fee)

    params =
      Map.merge(input_params, gateway_fee_params)
      |> Map.merge(%{
        user_id: input_params.user_id,
        total_transaction_amount: price,
        from_bsp: true,
        tudo_total_amount: tudo_amount,
        payment_method_token: token,
        business_id: business_id,
        paid_at: DateTime.utc_now(),
        currency_symbol: currency_symbol
      })

    case Payments.create_payment(params) do
      {:ok, data} ->
        {:ok, data}

      {:error, _} ->
        {:error, ["unable to create local payment"]}
    end
  end

  defp update_balance(
         %{
           create_payment: %{
             tudo_total_amount: tudo_amount,
             total_transaction_amount: bsp_spent_amount
           }
         },
         %{business_id: business_id} = _params
       ) do
    case Payments.get_balance_by_business(business_id) do
      nil ->
        attrs = %{
          tudo_balance: tudo_amount,
          bsp_spent_amount: bsp_spent_amount,
          business_id: business_id
        }

        case Payments.create_balance(attrs) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while creating balance"]}
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

  defp update_local_payment(
         %{create_payment: payment, local_subscription: %{id: sub_id, status_id: status}},
         _input_params
       ) do
    params = %{
      bsp_payment_status_id: status,
      payment_purpose: %{braintree_subscription_id: sub_id}
    }

    case Payments.update_payment(payment, params) do
      {:ok, data} ->
        {:ok, data}

      {:error, _} ->
        {:error, ["unable to create local payment"]}
    end
  end

  defp update_local_payment_price(
         %{update_payment: payment, bt_subscription: %{price: price}},
         _input_params
       ) do
    price = String.to_float(price)
    params = %{total_transaction_amount: price, tudo_total_amount: price}

    case Payments.update_payment(payment, params) do
      {:ok, data} ->
        {:ok, data}

      {:error, _} ->
        {:error, ["unable to create local payment"]}
    end
  end

  def payment_validation_on_each_billing_cycle(%{bt_subscription: %{id: sub_id}}, _input_params) do
    [%{start_date: start_date, subscription_bsp_rule_id: rule_id} = _subscription] =
      Payments.get_brain_tree_subscription_by(%{subscription_id: sub_id})

    %{package_validity: validity} = Payments.get_subscription_bsp_rule(rule_id)

    start_date = Timex.shift(Timex.to_datetime(start_date), seconds: 2)

    check_date = Timex.shift(start_date, months: String.to_integer(validity))

    Exq.enqueue_at(
      Exq,
      "default",
      #      Timex.shift(DateTime.utc_now(), seconds: 10),
      check_date,
      "CoreWeb.Workers.SubscriptionPaymentValidationWorker",
      [
        sub_id
      ]
    )

    {:ok, ["process enqueued!"]}
  end

  defp get_bt_subscription(%{subscription: %{subscription_id: id}}, %{options: opts}) do
    case Braintree.Subscription.find(id, [opts]) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Subscription"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Unable to fetch Braintree Subscription"]}
    end
  end

  defp get_bt_subscription(%{subscription: %{subscription_id: id}}, _) do
    case Braintree.Subscription.find(id) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Subscription"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Unable to fetch Braintree Subscription"]}
    end
  end

  defp update_bt_subscription(
         %{subscription: %{subscription_id: sub_id}},
         %{options: opts} = params
       ) do
    params = Map.drop(params, [:user_id, :business_id, :branch_id, :subscription_id, :password])

    case Braintree.Subscription.update(sub_id, params, [opts]) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Subscription"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Unable to update Braintree subscription"]}
    end
  end

  defp update_bt_subscription(%{subscription: %{subscription_id: sub_id}}, params) do
    params = Map.drop(params, [:user_id, :business_id, :branch_id, :subscription_id, :password])

    case Braintree.Subscription.update(sub_id, params) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["some thing went wrong with parameters for brain tree subscripion"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Unable to fetch Braintree Subscription"]}
    end
  end

  defp update_local_subscription(
         %{subscription: subscription, bt_subscription: %{id: id, status: status}},
         _
       ) do
    case Payments.update_brain_tree_subscription(
           subscription,
           %{subscription_id: id, status_id: String.downcase(status)}
         ) do
      {:ok, subscription} -> {:ok, subscription}
      {:error, _error} -> {:error, ["Unable to fetch Braintree Subscription"]}
    end
  end

  defp cancel_bt_subscription(%{subscription: %{subscription_id: sub_id}}, %{options: opts}) do
    case Braintree.Subscription.cancel(sub_id, [opts]) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Subscription"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Unable to cancel Braintree Subscription"]}
    end
  end

  defp cancel_bt_subscription(%{subscription: %{subscription_id: sub_id}}, _params) do
    case Braintree.Subscription.cancel(sub_id) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Subscription"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Unable to cancel Braintree Subscription"]}
    end
  end

  defp get_bt_subscriptions_by(_, %{options: opts} = params) do
    params = Map.drop(params, [:user_id])

    params =
      if Map.has_key?(params, :plan_id) do
        %{plan_id: %{is: params.plan_id}}
      else
        params
      end

    case Braintree.Subscription.search(params, [opts]) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Subscription"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Unable to fetch Braintree Subscription"]}
    end
  end

  defp get_bt_subscriptions_by(_, params) do
    params = Map.drop(params, [:user_id])

    params =
      if Map.has_key?(params, :plan_id) do
        %{plan_id: %{is: params.plan_id}}
      else
        params
      end

    case Braintree.Subscription.search(params) do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Subscription"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Unable to fetch Braintree Subscription"]}
    end
  end

  #  defp create_payment_method_nonce(%{token: %{token: payment_method_token}}, _) do
  #    case Braintree.PaymentMethodNonce.create(payment_method_token) do
  #      {:ok, nonce} -> {:ok, nonce}
  #      {:error, :forbidden} -> {:error, ["Something went wrong with parameters for Braintree Subscription"]}
  #      {:error, %{message: bt_error_message}} -> {:error, bt_error_message}
  #      _ -> {:error, ["Something went wrong, unable to create Payment Method Nonce"]}
  #    end
  #    rescue
  #      _ -> {:error, ["unable to fetch payment method nonce"]}
  #  end
end
