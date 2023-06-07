defmodule CoreWeb.Helpers.PaypalSubscriptionHelper do
  #   Core.PaypalPayments.Sages.Subscription
  @moduledoc false

  use CoreWeb, :core_helper

  import CoreWeb.Utils.Errors

  alias Core.{Payments, PaypalPayments}
  alias Core.PaypalPayments.SubscriptionHandler, as: Common
  alias CoreWeb.Controllers.PaypalPaymentController
  alias CoreWeb.GraphQL.Resolvers.PaypalPaymentResolver, as: R
  alias CoreWeb.Utils.CommonFunctions

  #  alias Core.Payments.TipsDonationsBspAmountsCalculator
  #  alias Core.Payments.TipsDonationsBspAmountsCalculator, as: AMC

  #
  # Main actions

  def create_paypal_subscription_plan(params) do
    new()
    |> run(:get_paypal_subscription_plan, &is_subscription_plan_exists/2, &abort/3)
    |> run(:paypal_product, &create_paypal_product/2, &abort/3)
    |> run(:paypal_subscription_plan, &create_paypal_subscription_plan/2, &abort/3)
    |> run(:local_paypal_subscription_plan, &create_local_paypal_subscription_plan/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  @spec update_paypal_subscription_plan(any) :: {:error, any} | {:ok, any, map}
  def update_paypal_subscription_plan(params) do
    new()
    |> run(:get_local_plan, &get_local_paypal_subscription_plan/2, &abort/3)
    #    |> run(:paypal_subscription_plan, &update_paypal_subscription_plan/2, &abort/3)
    |> run(:local_paypal_subscription_plan, &update_local_paypal_subscription_plan/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_paypal_subscription(params) do
    new()
    |> run(:business_subscription, &is_subscription_exists/2, &abort/3)
    |> run(:foreign_keys_validity, &foreign_keys_validity/2, &abort/3)
    |> run(:local_subscription_plan, &get_local_subscription_plan/2, &abort/3)
    |> run(:create_available_promotions, &create_available_promotions/2, &abort/3)
    |> run(:create_payment, &create_local_payment/2, &abort/3)
    |> run(:update_balance, &update_balance/2, &abort/3)
    |> run(:paypal_subscription, &create_paypal_subscription/2, &abort/3)
    |> run(:local_subscription, &create_local_subscription/2, &abort/3)
    |> run(:update_payment, &update_local_payment/2, &abort/3)
    #    |> run(:payment_validation_billing_cycle, &payment_validation_on_each_billing_cycle/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_paypal_subscription(params) do
    new()
    |> run(:business_subscription, &get_subscription/2, &abort/3)
    |> run(:expire_free_subscription, &make_free_subscription_expire/2, &abort/3)
    |> run(:zero_payment_expire, &make_default_zero_payment_expire/2, &abort/3)
    |> run(:confirmation, &confirm_subscription_activation/2, &abort/3)
    |> run(:local_subscription, &update_local_subscription/2, &abort/3)
    |> run(:local_payment, &update_local_payment/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  #  def get_brain_tree_subscription(params) do
  #    new()
  #    |> run(:subscription, &get_subscription/2, &abort/3)
  #    |> run(:bt_subscription, &get_bt_subscription/2, &abort/3)
  #    |> transaction(Core.Repo, params)
  #  end
  #  def retry_charge_brain_tree_subscription(params) do
  #    new()
  #    |> run(:subscription, &get_subscription/2, &abort/3)
  #    |> run(:bt_subscription, &retry_subscription/2, &abort/3)
  #    |> run(:local_subscription, &update_local_subscription/2, &abort/3)
  #    |> run(:create_payment, &create_local_payment/2, &abort/3)
  #    |> run(:update_payment, &update_local_payment/2, &abort/3)
  #    |> run(:update_payment_price, &update_local_payment_price/2, &abort/3)
  #    |> transaction(Core.Repo, params)
  #  end
  #  def update_brain_tree_subscription(params) do
  #    new()
  #    |> run(:subscription, &get_subscription/2, &abort/3)
  #    |> run(:bt_subscription, &update_bt_subscription/2, &abort/3)
  #    |> run(:local_subscription, &update_local_subscription/2, &abort/3)
  #    |> transaction(Core.Repo, params)
  #  end
  #  def cancel_brain_tree_subscription(params) do
  #    new()
  #    |> run(:subscription, &get_subscription/2, &abort/3)
  #    |> run(:bt_subscription, &cancel_bt_subscription/2, &abort/3)
  #    |> run(:local_subscription, &update_local_subscription/2, &abort/3)
  #    |> transaction(Core.Repo, params)
  #  end

  # --------------create_paypal_subscription_plan---------------------------------

  def is_subscription_plan_exists(_, %{slug: slug, country_id: country_id}) do
    case PaypalPayments.get_paypal_subscription_plan_by_country_and_slug(slug, country_id) do
      nil ->
        {:ok, ["valid"]}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["You already have Subscription plan against provided plan slug and Country"],
          __ENV__.line
        )
    end
  end

  defp create_paypal_product(_, _) do
    %{category: "services", name: "SERVICE", type: "SERVICE"}
    |> PaypalPaymentController.create_paypal_product()
  end

  defp create_paypal_subscription_plan(
         %{paypal_product: %{id: product_id}},
         %{name: name, country_id: country_id} = params
       ) do
    if params[:monthly_price] == 0 and params[:annual_price] == 0 do
      {:ok, %{id: nil}}
    else
      case PaypalPaymentController.get_access_token_for_paypal_requests() do
        {:error, error} ->
          {:error, error}

        {:ok,
         %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
          Common.creates_paypal_plan(
            name,
            country_id,
            access_token,
            paypal_partner_attribution_id,
            product_id,
            params
          )
      end
    end
  end

  defp create_local_paypal_subscription_plan(%{paypal_subscription_plan: %{id: plan_id}}, params) do
    case PaypalPayments.create_paypal_subscription_plan(
           Map.merge(params, %{paypal_plan_id: plan_id})
         ) do
      {:ok, plan} ->
        {:ok, plan}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Unable to create local Paypal Plan"], __ENV__.line)
    end
  end

  # --------------update_paypal_subscription_plan---------------------------------

  defp get_local_paypal_subscription_plan(_, %{id: plan_id}) do
    case PaypalPayments.get_paypal_subscription_plan(plan_id) do
      nil -> {:error, ["Local PayPal Plan does not exist"]}
      %{} = plan -> {:ok, plan}
    end
  end

  defp update_local_paypal_subscription_plan(%{get_local_plan: plan}, params) do
    params =
      Enum.reduce(params, params, fn {key, val}, acc ->
        prev_val = Map.get(plan, key) |> CommonFunctions.keys_to_atoms()

        if is_map(val) and is_map(prev_val) do
          Map.put(acc, key, Map.merge(prev_val, val))
        else
          acc
        end
      end)

    case PaypalPayments.update_paypal_subscription_plan(plan, params) do
      {:ok, plan} ->
        {:ok, plan}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Unable to update local PayPal Plan"], __ENV__.line)
    end
  end

  # --------------create_paypal_subscription---------------------------------

  def is_subscription_exists(_, %{business_id: bus_id}) do
    case PaypalPayments.get_paypal_subscription_by_business(bus_id) do
      [] ->
        {:ok, ["valid"]}

      [%{slug: "freelancer"}] ->
        {:ok, ["valid"]}

      [%{subscription_plan_id: id}] ->
        %{name: package} = PaypalPayments.get_paypal_subscription_plan(id)
        {:error, ["Your business already purchased the Package: #{package}"]}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["Your Business already enrolled for this Subscription package"],
          __ENV__.line
        )
    end
  end

  def foreign_keys_validity(_, parameters) do
    with {:ok, _data} <- get_subscription_bsp_rule(parameters),
         {:ok, _data} <- Common.get_user(parameters),
         {:ok, _data} <- Common.get_business(parameters) do
      {:ok, parameters}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Unexpected Error Occurred"], __ENV__.line)
    end
  end

  #  using nested cases
  defp get_local_subscription_plan(
         _,
         %{subscription_plan_id: rule, country_id: country_id} = params
       ) do
    case PaypalPayments.get_paypal_subscription_plan_by_country(rule, country_id) do
      nil ->
        {:error, ["Subscription rule/ plan does not exist for this Country"]}

      %{} = plan ->
        case Common.update_subscription_for_custom_items(plan, params) do
          {:error, error} ->
            {:error, error}

          plan ->
            case params do
              %{price: price} ->
                if CommonFunctions.compare_two_floats_with_buffer(price, plan.price) do
                  {:ok, plan}
                else
                  {:error, ["Could not verify plan price, calculated price is #{plan.price}"]}
                end

              _ ->
                {:ok, plan}
            end
        end
    end
  end

  #  using with statement
  #  defp get_local_subscription_plan(_, %{subscription_plan_id: rule, country_id: country_id} = params) do
  #    with %{} = plan <- PaypalPayments.get_paypal_subscription_plan_by_country(rule, country_id),
  #         %{} = plan <- Common.update_subscription_for_custom_items(plan, params),
  #         %{price: price} <- params do
  #      if CommonFunctions.compare_two_floats_with_buffer(price, plan.price) do
  #        {:ok, plan}
  #      else
  #        {:error, ["Could not verify plan price, calculated price is #{plan.price}"]}
  #      end
  #    else
  #      {:error, error} -> {:error, error}
  #      nil -> {:error, ["Subscription rule/ plan does not exist for this Country"]}
  #      %{} = plan -> {:ok, plan}
  #    end
  #  end

  def create_available_promotions(%{local_subscription_plan: plan}, %{
        business_id: business_id,
        subscription_plan_id: rule,
        country_id: country_id,
        annual: annual
      }) do
    case plan do
      %{promotions: %{"monthly_limit" => monthly_promotions, "annual_limit" => annual_promotions}} =
          plan ->
        promotions = if annual, do: annual_promotions, else: monthly_promotions

        if promotions == 0 or is_nil(promotions) do
          {:ok, ["You exceeded Promotion limit on your Subscription package"]}
        else
          list = Enum.to_list(1..promotions)

          promotions =
            Enum.reduce(list, [], fn _counter, acc ->
              case Common.create_available_promotion(%{
                     plan: plan,
                     annual: annual,
                     broad_cast_range: 30,
                     business_id: business_id,
                     rule_id: rule,
                     price: nil,
                     country_id: country_id
                   }) do
                {:ok, data} -> [data | acc]
                {:error, _error} -> acc
              end
            end)

          {:ok, promotions}
        end

      _ ->
        {:ok, ["no promotion needed to be created"]}
    end
  end

  def create_local_payment(
        %{local_subscription_plan: plan},
        %{business_id: business_id, country_id: _country_id, annual: annual} = input_params
      ) do
    price =
      case plan do
        %{price: price} ->
          price

        %{monthly_price: monthly_price, annual_price: annual_price} ->
          if annual, do: annual_price, else: monthly_price

        exception ->
          logger(
            __MODULE__,
            exception,
            ["Subscription rule/ plan does not exist for this Country"],
            __ENV__.line
          )
      end

    case price do
      {:error, error} ->
        {:error, error}

      price ->
        params =
          Map.merge(
            input_params,
            %{
              user_id: input_params.user_id,
              total_transaction_amount: price,
              paid_at: DateTime.utc_now(),
              tudo_total_amount: price,
              business_id: business_id,
              from_bsp: true,
              currency_symbol: "$"
            }
          )

        case Payments.create_payment(params) do
          {:ok, data} ->
            {:ok, data}

          {:error, _} ->
            {:error, ["unable to create local payment"]}
        end
    end
  end

  def update_balance(
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

      exception ->
        logger(__MODULE__, exception, ["Error while getting balance"], __ENV__.line)
    end
  end

  def create_paypal_subscription(
        %{local_subscription_plan: %{paypal_plan_id: plan_id, currency: currency} = plan},
        params
      ) do
    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
        #        paypal_partner_attribution_id = "FLAVORsb-cxm47s5549184_MP"
        url = System.get_env("PAYPAL_SUBSCRIPTION_URL")

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token},
          {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id},
          {"PayPal-Request-Id", UUID.uuid1()}
          #      {"PayPal-Auth-Assertion", access_token}
        ]

        customized_plan = Common.make_plan_customized(currency, params, plan)
        _subscriber = Common.get_subscriber(params)

        input =
          Map.drop(params, [
            :access_token,
            :country_id,
            :annual,
            :user_id,
            :payment_method_id,
            :promotions,
            :branches,
            :employees,
            :price
          ])

        input =
          Map.merge(input, %{
            plan_id: plan_id,
            plan: customized_plan,
            application_context: %{
              return_url: "https://tudo.app/pages/payments-success",
              cancel_url: "https://tudo.app/pages/payments-error"
            }
          })

        body = Poison.encode!(input)

        case HTTPoison.post(url, body, headers, hackney: [basic_auth: R.auth()]) do
          {:ok, data} ->
            case Poison.decode(data.body) do
              {:error, error, _} ->
                {:error, error}

              {:error, error} ->
                {:error, error}

              {:ok, %{"error_description" => error}} ->
                {:error, error}

              {:ok, %{"message" => _, "details" => [%{"description" => error} | _]}} ->
                {:error, error}

              {:ok, %{"links" => _links} = data} ->
                data =
                  if false == is_nil(data["create_time"]) do
                    {_, create_time, _} = DateTime.from_iso8601(data["create_time"])
                    Map.merge(data, %{"create_time" => create_time})
                  else
                    data
                  end

                {:ok, CommonFunctions.keys_to_atoms(data)}

              exception ->
                logger(__MODULE__, exception, ["No case clause matching"], __ENV__.line)
            end

          exception ->
            logger(__MODULE__, exception, ["Unable to create paypal subscription"], __ENV__.line)
        end
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong while creating Paypal Subscription"],
        __ENV__.line
      )
  end

  defp create_local_subscription(
         %{paypal_subscription: %{id: sub_id, status: status}, local_subscription_plan: plan},
         %{subscription_plan_id: plan_id, country_id: country_id, annual: annual} = params
       ) do
    plan = Common.update_plan_usage_information(plan, annual)

    plan =
      if annual == false,
        do: Map.merge(plan, %{annual_price: nil}),
        else: Map.merge(plan, %{monthly_price: nil})

    currency_symbol =
      case Core.Regions.get_countries(country_id) do
        %{currency_symbol: symbol} -> symbol
        _ -> ""
      end

    months = if annual, do: 12, else: 1
    end_date = Timex.shift(Date.utc_today(), months: months)

    params =
      Map.merge(params, %{
        start_date: Date.utc_today(),
        expiry_date: end_date,
        paypal_subscription_id: sub_id,
        status_id: String.downcase(status),
        subscription_plan_id: plan_id,
        currency_symbol: currency_symbol
      })
      |> Map.merge(plan)

    case PaypalPayments.create_paypal_subscription(params) do
      {:ok, data} ->
        {:ok, data}

      {:error, _} ->
        {:error, ["unable to create local subscription"]}
    end
  end

  defp update_local_payment(
         %{
           create_payment: payment,
           paypal_subscription: %{id: paypal_sub_id},
           local_subscription: %{id: sub_id, status_id: status}
         },
         _input_params
       ) do
    params = %{
      bsp_payment_status_id: status,
      payment_purpose: %{paypal_subscription_id: sub_id},
      transaction_id: paypal_sub_id
    }

    case Payments.update_payment(payment, params) do
      {:ok, data} -> {:ok, data}
      {:error, _} -> {:error, ["unable to create local payment"]}
    end
  end

  defp update_local_payment(%{business_subscription: %{id: sub_id}}, _input_params) do
    case Payments.get_payment_by_subscription_id(sub_id) do
      nil ->
        {:ok, ["no payment to be updated"]}

      %{} = payment ->
        case Payments.update_payment(payment, %{bsp_payment_status_id: "active"}) do
          {:ok, data} -> {:ok, data}
          {:error, _} -> {:error, ["unable to update local payment"]}
        end
    end
  end

  # --------------update_paypal_subscription---------------------------------

  defp get_subscription(_, %{business_id: bus_id}) do
    case PaypalPayments.get_paypal_business_subscription_for_activation(bus_id) do
      nil -> {:error, ["Subscription Doesn't Exist"]}
      %{} = subscription -> {:ok, subscription}
    end
  end

  defp get_subscription_bsp_rule(%{subscription_plan_id: subscription_plan_id}) do
    case PaypalPayments.get_paypal_subscription_plan(subscription_plan_id) do
      nil ->
        {:error, ["This Subscription plan doesn't exist!"]}

      %{} = data ->
        {:ok, data}

      exception ->
        logger(__MODULE__, exception, ["Unexpected error occurred."], __ENV__.line)
    end
  end

  defp get_subscription_bsp_rule(_params), do: {:ok, ["valid"]}

  def make_free_subscription_expire(_, %{business_id: bus_id}) do
    case PaypalPayments.get_paypal_subscription_by_business(bus_id) do
      [%{slug: "freelancer"} = sub] ->
        PaypalPayments.update_paypal_subscription(sub, %{status_id: "expired"})

      _ ->
        {:ok, ["valid"]}
    end
  end

  defp make_default_zero_payment_expire(_, %{business_id: bus_id}) do
    case Payments.get_default_zero_payment_by_business(bus_id) do
      nil -> {:ok, ["no payment to be expired"]}
      %{} = payment -> Payments.update_payment(payment, %{bsp_payment_status_id: "waiting"})
    end
  end

  def confirm_subscription_activation(
        %{business_subscription: %{paypal_subscription_id: paypal_subscription_id}},
        _
      ) do
    case Common.get_paypal_subscription(paypal_subscription_id) do
      {:error, error} ->
        {:error, error}

      {:ok, data} ->
        if data["status"] == "ACTIVE",
          do: {:ok, data},
          else: {:error, ["Payment is not verified"]}
    end
  end

  defp update_local_subscription(%{business_subscription: subscription}, params) do
    case PaypalPayments.update_paypal_subscription(subscription, params) do
      {:ok, data} -> {:ok, data}
      {:error, _} -> {:error, ["unable to update local subscription"]}
    end
  end

  # ---------------------------------------------------------------------------

  #  defp get_subscription_status(%{status_id: status}) do
  #    case Payments.get_brain_tree_subscription_statuses(status) do
  #      nil -> {:error, ["This Braintree Subscription status doesn't exist!"]}
  #      %{} = data -> {:ok, data}
  #      _ -> {:error, ["unexpected error occurred!"]}
  #    end
  #  end
  #  defp get_subscription_status(_params) do
  #    {:ok, ["valid"]}
  #  end
  #  def payment_validation_on_each_billing_cycle(%{paypal_subscription: %{id: sub_id}}, _input_params) do
  #
  #    [%{start_date: start_date, subscription_bsp_rule_id: rule_id} = _subscription] =
  #      Payments.get_brain_tree_subscription_by(%{subscription_id: sub_id})
  #
  #    %{package_validity: validity} = Payments.get_subscription_bsp_rule(rule_id)
  #
  #    start_date = Timex.shift(Timex.to_datetime(start_date), seconds: 2)
  #
  #    check_date = Timex.shift(start_date, months: String.to_integer(validity))
  #    Exq.enqueue_at(
  #      Exq,
  #      "default",
  #      #      Timex.shift(DateTime.utc_now(), seconds: 10),
  #      check_date,
  #      "CoreWeb.Workers.SubscriptionPaymentValidationWorker",
  #      [
  #        sub_id
  #      ]
  #    )
  #    {:ok, ["process enqueued!"]}
  #  end
end
