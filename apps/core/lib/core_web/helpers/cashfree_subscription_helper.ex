defmodule CoreWeb.Helpers.CashfreeSubscriptionHelper do
  @moduledoc false
  use CoreWeb, :core_helper

  alias Core.{Payments, PaypalPayments}
  alias Core.PaypalPayments.SubscriptionHandler, as: Common
  alias Core.Schemas.PaypalSubscriptionPlan
  alias CoreWeb.Utils.{CommonFunctions, HttpRequest}

  alias CoreWeb.GraphQL.Resolvers.CashfreeResolver, as: CFResolver
  alias CoreWeb.Helpers.PaypalSubscriptionHelper, as: PaypalHelper

  # Main actions

  def create_cashfree_subscription_plan(params) do
    new()
    |> run(:get_paypal_subscription_plan, &is_subscription_plan_exists/2, &abort/3)
    |> run(:cashfree_subscription_plan, &create_cashfree_subscription_plan/2, &abort/3)
    |> run(:local_paypal_subscription_plan, &create_local_paypal_subscription_plan/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_cashfree_subscription(params) do
    new()
    |> run(:subscription_exists, &PaypalHelper.is_subscription_exists/2, &abort/3)
    |> run(:local_subscription_plan, &get_local_subscription_plan/2, &abort/3)
    |> run(:create_available_promotions, &PaypalHelper.create_available_promotions/2, &abort/3)
    |> run(:create_payment, &PaypalHelper.create_local_payment/2, &abort/3)
    |> run(:update_balance, &PaypalHelper.update_balance/2, &abort/3)
    |> run(:expire_free_subscription, &PaypalHelper.make_free_subscription_expire/2, &abort/3)
    |> run(:local_subscription, &create_local_subscription/2, &abort/3)
    |> run(:cashfree_subscription, &create_cashfree_subscription/2, &abort/3)
    |> run(:update_payment, &update_local_payment/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # --------------create_cashfree_subscription_plan---------------------------------

  defp is_subscription_plan_exists(_, %{slug: slug, country_id: country_id}) do
    case PaypalPayments.get_paypal_subscription_plan_by_country_and_slug(slug, country_id) do
      %PaypalSubscriptionPlan{} = data ->
        {:ok, data}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["You already have Subscription plan against provided plan slug and Country"],
          __ENV__.line
        )
    end
  end

  defp create_cashfree_subscription_plan(
         %{get_paypal_subscription_plan: %{name: plan_name, monthly_price: monthly_price}},
         _
       ) do
    url = System.get_env("CASHFREE_PLAN_URL")

    headers = [
      {"Content-Type", "application/json"},
      {"x-api-version", System.get_env("CASHFREE_X_API_VERSION")},
      {"x-client-id", System.get_env("CASHFREE_X_CLIENT_ID")},
      {"x-client-secret", System.get_env("CASHFREE_X_CLIENT_SECRET")}
    ]

    plan_id = CommonFunctions.string()

    input = %{
      planName: plan_name,
      planId: plan_id,
      type: "ON_DEMAND",
      maxAmount: monthly_price
    }

    case HttpRequest.post(url, input, headers, hackney: [basic_auth: CFResolver.auth()]) do
      {:ok, _data} -> {:ok, plan_id}
      {:error, error} -> {:error, error}
    end
  end

  defp create_local_paypal_subscription_plan(
         %{
           get_paypal_subscription_plan: paypal_subscription_plan,
           cashfree_subscription_plan: plan_id
         },
         _
       ) do
    case PaypalPayments.update_paypal_subscription_plan(paypal_subscription_plan, %{
           cashfree_plan_id: plan_id
         }) do
      {:ok, updated_data} ->
        {:ok, updated_data}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Unable to create local Cashfree Plan"], __ENV__.line)
    end
  end

  # --------------create_cashfree_subscription---------------------------------

  defp get_local_subscription_plan(
         _,
         %{subscription_plan_id: plan_id, country_id: country_id} = params
       ) do
    case PaypalPayments.get_paypal_subscription_plan_by_country(plan_id, country_id) do
      nil ->
        {:error, ["Subscription rule/ plan does not exist for this Country"]}

      %{cashfree_plan_id: cf_plan_id} = plan ->
        case Common.update_subscription_for_custom_items(plan, params) do
          {:error, error} ->
            {:error, error}

          plan ->
            case params do
              %{price: price} ->
                if CommonFunctions.compare_two_floats_with_buffer(price, plan.price) do
                  {:ok,
                   plan
                   |> Map.merge(%{cashfree_plan_id: cf_plan_id})}
                else
                  {:error, ["Could not verify plan price, calculated price is #{plan.price}"]}
                end

              _ ->
                {:ok, plan}
            end
        end
    end
  end

  defp create_cashfree_subscription(%{local_subscription_plan: plan}, _params) do
    url =
      System.get_env("CASHFREE_SUBSCRIPTION_URL") ||
        "https://test.cashfree.com/api/v2/subscriptions"

    headers = [
      {"Content-Type", "application/json"},
      {"x-api-version", System.get_env("CASHFREE_X_API_VERSION")},
      {"x-client-id", System.get_env("CASHFREE_X_CLIENT_ID")},
      {"x-client-secret", System.get_env("CASHFREE_X_CLIENT_SECRET")}
    ]

    sub_id = CommonFunctions.string()

    input = %{
      subscriptionId: sub_id,
      planId: plan.cashfree_plan_id,
      customerName: "Ahmad",
      customerEmail: "abc@test.com",
      customerPhone: "03211234567",
      returnUrl: "http://localhost:4000/graphiql"
    }

    case HttpRequest.post(url, input, headers, hackney: [basic_auth: CFResolver.auth()]) do
      {:ok, _data} -> {:ok, %{subscription_id: sub_id}}
      {:error, error} -> {:error, error}
    end
  end

  defp create_local_subscription(
         %{
           #           cashfree_subscription: %{id: sub_id, status: status},
           local_subscription_plan: plan
         },
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
        #        paypal_subscription_id: sub_id,
        status_id: "active",
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
           cashfree_subscription: %{subscription_id: cashfree_sub_id},
           local_subscription: %{
             id: sub_id
             #  , status_id: status
           }
         },
         _input_params
       ) do
    params = %{
      #      bsp_payment_status_id: status,
      payment_purpose: %{cashfree_subscription_id: sub_id},
      transaction_id: cashfree_sub_id
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
end
