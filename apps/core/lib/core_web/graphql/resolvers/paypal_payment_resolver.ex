defmodule CoreWeb.GraphQL.Resolvers.PaypalPaymentResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias Core.{PaypalPayments, Payments}
  alias CoreWeb.Controllers.HyperWalletPaymentController
  alias CoreWeb.Controllers.PaypalPaymentController
  alias CoreWeb.Utils.HttpRequest
  alias alias CoreWeb.GraphQL.Resolvers.OrderResolver

  @default_error ["unexpected error occurred"]

  def auth, do: {System.get_env("PAYPAL_CLIENT_ID"), System.get_env("PAYPAL_SECRET_ID")}

  def get_paypal_access_token(_, _, _) do
    case PaypalPaymentController.get_paypal_access_token() do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def create_seller_account(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case input do
      %{paypal_account: paypal_account} ->
        params = Map.merge(paypal_account, %{user_id: current_user.id, user: current_user})

        case PaypalPaymentController.create_paypal_seller_account(params) do
          {:ok, data} ->
            {:ok, data}

          {:error, error}
          when error in [
                 "Access Token not found in cache",
                 "The token passed in was not found in the system"
               ] ->
            refresh_token(1, 1, 1)
            PaypalPaymentController.create_paypal_seller_account(params)

          {:error, error} ->
            {:error, error}
        end

      %{hyper_wallet_account: hyper_wallet_account} ->
        params = Map.merge(hyper_wallet_account, %{user_id: current_user.id, user: current_user})
        HyperWalletPaymentController.create_hyper_wallet_user(params)

      _ ->
        {:error, ["neither paypal nor hyper wallet params in input"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_paypal_seller_account(_, %{input: input}, %{context: %{current_user: current_user}}) do
    params = Map.merge(input, %{user_id: current_user.id, user: current_user})

    case PaypalPaymentController.update_paypal_seller_account(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def delete_paypal_seller_account(_, %{input: input}, %{context: %{current_user: current_user}}) do
    params = Map.merge(input, %{user_id: current_user.id, user: current_user})

    case PaypalPaymentController.delete_paypal_seller_account(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def get_seller_accounts_by_user(_, _, %{context: %{current_user: current_user}}) do
    case PaypalPaymentController.get_paypal_seller_accounts_by_user(%{user_id: current_user.id}) do
      {:ok, paypal_accounts} -> {:ok, paypal_accounts}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  # ------------------------------------Paypal Order-------------------------------------------
  def create_paypal_order(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input =
      Map.merge(input, %{
        user_id: current_user.id,
        user: current_user,
        country_id: current_user.country_id
      })

    case is_order_already_exist(input) do
      nil ->
        case PaypalPaymentController.create_paypal_order(input) do
          {:ok, data} ->
            {:ok, data}

          {:error, error}
          when error in [
                 "Access Token not found in cache",
                 "The token passed in was not found in the system"
               ] ->
            refresh_token(1, 1, 1)
            PaypalPaymentController.create_paypal_order(input)

          {:error, error} ->
            {:error, error}
        end

      %{transaction_id: transaction_id} ->
        case PaypalPaymentController.get_paypal_order(transaction_id) do
          {:ok, data} ->
            {:ok, data}

          {:error, error} ->
            {:error, error}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def capture_paypal_order(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input =
      Map.merge(input, %{
        user: current_user,
        user_id: current_user.id,
        country_id: current_user.country_id
      })

    case PaypalPaymentController.capture_paypal_order(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, error}
      when error in [
             "Access Token not found in cache",
             "The token passed in was not found in the system"
           ] ->
        refresh_token(1, 1, 1)
        PaypalPaymentController.capture_paypal_order(input)

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def get_paypal_order(_, %{input: %{access_token: access_token, url: url}}, %{
        context: %{current_user: _current_user}
      }) do
    paypal_partner_attribution_id = "FLAVORsb-cxm47s5549184_MP"

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer " <> access_token},
      {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id}
    ]

    case HttpRequest.get(url, headers, hackney: [basic_auth: auth()]) do
      {:ok, data} -> {:ok, keys_to_atoms(data)}
      {:error, error} -> {:error, error}
    end
  end

  def create_paypal_product(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    case PaypalPaymentController.create_paypal_product(input) do
      {:error, error} -> {:error, error}
      {:ok, product} -> {:ok, product}
    end
  end

  def create_paypal_plan(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case PaypalPaymentController.create_paypal_plan(Map.merge(input, %{user_id: current_user.id})) do
      {:ok, data} ->
        {:ok, data}

      {:error, error}
      when error in [
             "Access Token not found in cache",
             "The token passed in was not found in the system"
           ] ->
        refresh_token(1, 1, 1)
        PaypalPaymentController.create_paypal_plan(Map.merge(input, %{user_id: current_user.id}))

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create PayPal plan"], __ENV__.line)
  end

  def update_paypal_plan(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case PaypalPaymentController.update_paypal_plan(Map.merge(input, %{user_id: current_user.id})) do
      {:ok, data} ->
        {:ok, data}

      {:error, error}
      when error in [
             "Access Token not found in cache",
             "The token passed in was not found in the system"
           ] ->
        refresh_token(1, 1, 1)
        PaypalPaymentController.update_paypal_plan(Map.merge(input, %{user_id: current_user.id}))

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to update PayPal plan"], __ENV__.line)
  end

  def paypal_subscription_plans_by_country(_, %{input: input}, _) do
    plans =
      PaypalPayments.get_paypal_subscription_plans_by(input)
      |> Enum.map(&separate_plan_cmr_bsp_common_features(&1))

    {:ok, plans}
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to get PayPal plan"], __ENV__.line)
  end

  defp separate_plan_cmr_bsp_common_features(plan) do
    plan = check_plan_discount(plan)

    Enum.reduce(Map.from_struct(plan), %Core.Schemas.PaypalSubscriptionPlan{}, fn {k, v}, acc ->
      case v do
        %{"active" => active, "included" => included} when not active or not included ->
          acc

        _ ->
          str_key = if is_atom(k), do: to_string(k), else: k

          cond do
            String.starts_with?(str_key, "cmr_") ->
              acc =
                if Map.has_key?(acc, :cmr_common_features),
                  do: acc,
                  else: Map.merge(acc, %{cmr_common_features: %{}})

              Map.merge(acc, %{
                cmr_common_features: Map.merge(acc.cmr_common_features, Map.put(%{}, k, v))
              })

            String.starts_with?(str_key, "bsp_") ->
              acc =
                if Map.has_key?(acc, :bsp_common_features),
                  do: acc,
                  else: Map.merge(acc, %{bsp_common_features: %{}})

              Map.merge(acc, %{
                bsp_common_features: Map.merge(acc.bsp_common_features, Map.put(%{}, k, v))
              })

            true ->
              Map.merge(acc, Map.put(%{}, k, v))
          end
      end
    end)
  end

  defp check_plan_discount(%{plan_discount: plan_discount} = plan)
       when not is_nil(plan_discount) do
    with {:ok, begin_date, _} <- DateTime.from_iso8601(plan_discount["begin_date"]),
         {:ok, end_date, _} <- DateTime.from_iso8601(plan_discount["end_date"]) do
      if Timex.between?(DateTime.utc_now(), begin_date, end_date, inclusive: true) do
        plan
      else
        Map.merge(plan, %{plan_discount: nil})
      end
    else
      _ -> plan
    end
  end

  defp check_plan_discount(plan), do: plan

  def create_paypal_subscription(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case PaypalPaymentController.create_paypal_subscription(
           Map.merge(input, %{user_id: current_user.id})
         ) do
      {:ok, data} ->
        {:ok, data}

      {:error, error}
      when error in [
             "Access Token not found in cache",
             "The token passed in was not found in the system"
           ] ->
        refresh_token(1, 1, 1)

        PaypalPaymentController.create_paypal_subscription(
          Map.merge(input, %{user_id: current_user.id})
        )

      {:error, error} ->
        {:error, error}
    end
  end

  def update_paypal_subscription(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    case PaypalPaymentController.update_paypal_subscription(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, error}
      when error in [
             "Access Token not found in cache",
             "The token passed in was not found in the system"
           ] ->
        refresh_token(1, 1, 1)
        PaypalPaymentController.update_paypal_subscription(input)

      {:error, error} ->
        {:error, error}
    end
  end

  def paypal_subscription_by_business(_, %{input: input}, _) do
    case PaypalPaymentController.paypal_subscription_by_business(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, error}
      when error in [
             "Access Token not found in cache",
             "The token passed in was not found in the system"
           ] ->
        refresh_token(1, 1, 1)
        PaypalPaymentController.paypal_subscription_by_business(input)

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to get PayPal subscription"], __ENV__.line)
  end

  def create_paypal_payout(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id, country_id: current_user.country_id})

    case PaypalPaymentController.create_paypal_payout(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, error}
      when error in [
             "Access Token not found in cache",
             "The token passed in was not found in the system"
           ] ->
        refresh_token(1, 1, 1)
        PaypalPaymentController.create_paypal_payout(input)

      {:error, error} ->
        {:error, error}
    end
  end

  def refresh_token(_, _, _) do
    case CoreWeb.Controllers.PaypalPaymentController.get_paypal_access_token() do
      {:ok, %{access_token: access_token} = token_data} ->
        local_token =
          case PaypalPayments.get_paypal_access_token_for_update() do
            nil ->
              #            %{access_token: access_token, partner_attribution_id: "FLAVORsb-cxm47s5549184_MP"}
              %{access_token: access_token, partner_attribution_id: "FLAVORsb-naupg6018429_MP"}
              |> PaypalPayments.create_paypal_access_attributes()

            attr ->
              PaypalPayments.update_paypal_access_attributes(attr, %{access_token: access_token})
          end

        case local_token do
          {:ok, data} ->
            seconds = rem(token_data.expires_in, 60)
            min_hours = trunc((token_data.expires_in - seconds) / 60)
            minutes = rem(min_hours, 60)
            hours = trunc((min_hours - minutes) / 60)
            expires_in_time = "#{hours} Hours #{minutes} Minutes #{seconds} Seconds"
            {:ok, Map.merge(data, token_data) |> Map.merge(%{expires_after: expires_in_time})}

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  def authorize_payment(
        _,
        %{input: %{paypal_order_id: paypal_order_id, product_order_id: product_order_id}},
        _
      ) do
    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:ok, %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
        url = System.get_env("PAYPAL_ORDER_URL") <> "/#{paypal_order_id}" <> "/authorize"

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token},
          {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id}
        ]

        case HttpRequest.post(url, %{}, headers, hackney: [basic_auth: auth()]) do
          {:ok, %{"purchase_units" => purchase_units} = data} ->
            [h | _t] = purchase_units
            [authorizations | _] = h["payments"]["authorizations"]

            OrderResolver.update_order_status(product_order_id, %{
              status_id: "authorize",
              authorization_id: authorizations["id"]
            })

            make_local_payment_auhtorize_for_cmr(paypal_order_id)

            {:ok, keys_to_atoms(data)}

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def is_order_already_exist(input) do
    if Map.has_key?(input, :order_id) do
      Payments.get_payment_by_order_id(input.order_id)
    else
      Payments.get_payment_by_job_id(input.job_id)
    end
  end

  def make_local_payment_auhtorize_for_cmr(paypal_order_id) do
    case Payments.get_payment_by_transaction_id(paypal_order_id) do
      nil ->
        {:error, ["order does not exist"]}

      payment ->
        case Payments.update_payment(
               payment,
               %{cmr_payment_status_id: "authorize", paid_at: DateTime.utc_now()}
             ) do
          {:ok, transaction} -> {:ok, transaction}
          {:error, error} -> {:error, error}
        end
    end
  end
end
