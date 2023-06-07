defmodule CoreWeb.Controllers.PaypalPaymentController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.PaypalPayments
  alias CoreWeb.GraphQL.Resolvers.PaypalPaymentResolver, as: R
  alias CoreWeb.Utils.HttpRequest

  alias CoreWeb.Helpers.{
    PaypalOrderHelper,
    PaypalPayoutHelper,
    PaypalSellerHelper,
    PaypalSubscriptionHelper
  }

  def get_paypal_access_token do
    url = System.get_env("PAYPAL_ACCESS_TOKEN_URL")

    if false == is_nil(url) do
      #    account_id = "7KZZ4KYP75QNE"
      headers = [
        {"Accept", "application/json"},
        {"Content-Type", "application/x-www-form-urlencoded"}
      ]

      urlencoded_body = URI.encode_query(%{grant_type: "client_credentials"})

      case HTTPoison.post(url, urlencoded_body, headers, hackney: [basic_auth: R.auth()]) do
        {:ok, data} ->
          case Poison.decode(data.body) do
            {:ok, %{"error_description" => error}} -> {:error, error}
            {:ok, %{"access_token" => _} = data} -> {:ok, keys_to_atoms(data)}
            _ -> {:error, ["No case clause matching"]}
          end

        {:error, error} ->
          {:error, error}

        exception ->
          logger(__MODULE__, exception, ["Unable to get Paypal Access Token"], __ENV__.line)
      end
    else
      {:error, ["URL for request not supplied"]}
    end
  end

  def create_paypal_seller_account(input) do
    with {:ok, _last, all} <- PaypalSellerHelper.create_paypal_seller_account(input),
         %{paypal_seller_account: seller, local_seller_account: local_seller_account} <- all do
      seller = if is_map(seller), do: seller, else: local_seller_account
      {:ok, seller}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Unexpected Error Occurred"], __ENV__.line)
    end
  end

  def update_paypal_seller_account(input) do
    with {:ok, _last, all} <- PaypalSellerHelper.update_paypal_seller_account(input),
         %{local_seller_account: local_seller_account} <- all do
      {:ok, local_seller_account}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
    end
  end

  def delete_paypal_seller_account(input) do
    with {:ok, _last, all} <- PaypalSellerHelper.delete_paypal_seller_account(input),
         %{local_seller_account: local_seller_account} <- all do
      {:ok, local_seller_account}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def get_paypal_seller_accounts_by_user(input) do
    with {:ok, _last, all} <- PaypalSellerHelper.get_paypal_seller_accounts_by_user(input),
         %{paypal_seller_accounts: sellers} <- all do
      {:ok, sellers}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def create_paypal_order(input) do
    with {:ok, _last, all} <- PaypalOrderHelper.create_paypal_order(input),
         %{paypal_order: order} <- all do
      {:ok, order}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def get_paypal_order(transaction_id) do
    with {:ok, _last, all} <- PaypalOrderHelper.get_paypal_order(transaction_id),
         %{paypal_order: order} <- all do
      {:ok, order}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def capture_paypal_order(input) do
    with {:ok, _last, all} <- PaypalOrderHelper.capture_paypal_order(input),
         %{paypal_order: order} <- all do
      {:ok, order}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def create_paypal_plan(input) do
    with {:ok, _last, all} <- PaypalSubscriptionHelper.create_paypal_subscription_plan(input),
         %{local_paypal_subscription_plan: plan} <- all do
      {:ok, plan}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Unexpected Error Occurred"], __ENV__.line)
    end
  end

  def update_paypal_plan(input) do
    with {:ok, _last, all} <- PaypalSubscriptionHelper.update_paypal_subscription_plan(input),
         %{local_paypal_subscription_plan: plan} <- all do
      {:ok, plan}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def create_paypal_subscription(input) do
    with {:ok, _last, all} <- PaypalSubscriptionHelper.create_paypal_subscription(input),
         %{local_subscription: local_sub, paypal_subscription: paypal_sub} <- all do
      {:ok, Map.merge(paypal_sub, local_sub)}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def update_paypal_subscription(input) do
    with {:ok, _last, all} <- PaypalSubscriptionHelper.update_paypal_subscription(input),
         %{local_subscription: local_sub} <- all do
      {:ok, local_sub}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def create_paypal_payout(input) do
    with {:ok, _last, all} <- PaypalPayoutHelper.create_paypal_payout(input),
         %{paypal_payout: paypal_payout} <- all do
      {:ok, paypal_payout}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def create_paypal_product(input) do
    case get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
        url = System.get_env("PAYPAL_PRODUCT_URL")

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token},
          {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id},
          {"PayPal-Request-Id", UUID.uuid1()}
        ]

        case HttpRequest.post(url, input, headers, hackney: [basic_auth: R.auth()]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
        end
    end
  end

  def paypal_subscription_by_business(%{business_id: business_id}) do
    {:ok, PaypalPayments.get_paypal_subscription_by_business(business_id)}
  end

  def get_access_token_for_paypal_requests do
    case PaypalPayments.get_paypal_access_token() do
      nil -> create_new_access_token()
      token -> {:ok, token}
    end
  end

  def create_new_access_token do
    case get_paypal_access_token() do
      {:ok, %{access_token: access_token, expires_in: expires_in}} ->
        expires_in =
          case PaypalPayments.get_paypal_access_token_for_update() do
            nil ->
              %{access_token: access_token, partner_attribution_id: "FLAVORsb-cxm47s5549184_MP"}
              |> PaypalPayments.create_paypal_access_attributes()

              {:ok, expires_in}

            attr ->
              PaypalPayments.update_paypal_access_attributes(attr, %{access_token: access_token})
              {:ok, expires_in}
          end

        expires_in =
          case expires_in do
            {:ok, expires_in} when is_integer(expires_in) -> expires_in
            _ -> 32_400
          end

        Exq.enqueue_in(
          Exq,
          "default",
          expires_in,
          "CoreWeb.Workers.PaypalAccessTokenUpdateWorker",
          []
        )

        get_access_token_for_paypal_requests()

      {:error, error} ->
        {:error, error}
    end
  end
end
