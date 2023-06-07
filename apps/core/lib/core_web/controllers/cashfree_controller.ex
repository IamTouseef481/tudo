defmodule CoreWeb.Controllers.CashfreeController do
  @moduledoc false

  use CoreWeb, :controller

  alias CoreWeb.Helpers.{
    CashfreeHelper,
    CashfreeSubscriptionHelper,
    CashfreeBeneficiaryHelper,
    CashfreePayoutHelper
  }

  @default_error ["Unexpected Error Occurred"]

  def create_cashfree_order(%{with_pay: true} = input) do
    case CashfreeHelper.create_cashfree_order(input) do
      {:ok, _last, %{cashfree_order: order, cashfree_order_payment: order_pay} = _all} ->
        {:ok, Map.merge(order, order_pay)}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, @default_error, __ENV__.line)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def create_cashfree_order(input) do
    case CashfreeHelper.create_cashfree_order(input) do
      {:ok, _last, %{cashfree_order: order} = _all} ->
        {:ok, order}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, @default_error, __ENV__.line)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_payment_when_order_pay(input) do
    case CashfreeHelper.update_payment_when_order_pay(input) do
      {:ok, _last, %{cashfree_order: order} = _all} ->
        {:ok, order}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, @default_error, __ENV__.line)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def create_cashfree_plan(input) do
    case CashfreeSubscriptionHelper.create_cashfree_subscription_plan(input) do
      {:ok, _last, %{local_paypal_subscription_plan: plan}} -> {:ok, plan}
      {:error, error} -> {:error, error}
      _ -> {:error, "Something went wrong"}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unexpected Error Occurred"], __ENV__.line)
  end

  def create_cashfree_subscription(input) do
    case CashfreeSubscriptionHelper.create_cashfree_subscription(input) do
      {:ok, _last, %{local_subscription: subscription}} -> {:ok, subscription}
      {:error, error} -> {:error, error}
      _ -> {:error, "Something went wrong"}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unexpected Error Occurred"], __ENV__.line)
  end

  def create_beneficiary(input) do
    case CashfreeBeneficiaryHelper.create_beneficiary(input) do
      {:ok, _last, %{local_cashfree_beneficiary: beneficiary}} -> {:ok, beneficiary}
      {:error, error} -> {:error, error}
      _ -> {:error, "Something went wrong"}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unexpected Error Occurred"], __ENV__.line)
  end

  def delete_beneficiary(input) do
    case CashfreeBeneficiaryHelper.delete_beneficiary(input) do
      {:ok, _last, %{local_beneficiary: beneficiary}} -> {:ok, beneficiary}
      {:error, error} -> {:error, error}
      _ -> {:error, "Something went wrong"}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unexpected Error Occurred"], __ENV__.line)
  end

  def create_cashfree_payout(input) do
    with {:ok, _last, all} <- CashfreePayoutHelper.create_cashfree_payout(input),
         %{cashfree_payout: cashfree_payout} <- all do
      {:ok, cashfree_payout}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def get_bearer_token_for_payout_requests() do
    url = System.get_env("CASHFREE_PAYOUT_AUTHORIZE_URL")

    headers = [
      {"X-Client-Id", System.get_env("CASHFREE_PAYOUT_X_CLIENT_ID")},
      {"X-Client-Secret", System.get_env("CASHFREE_PAYOUT_X_CLIENT_SECRET")},
      {"accept", "application/json"}
    ]

    case CoreWeb.Utils.HttpRequest.post(url, %{}, headers, hackney: []) do
      {:ok, token} -> {:ok, token}
      {:error, error} -> {:error, error}
    end
  end
end
