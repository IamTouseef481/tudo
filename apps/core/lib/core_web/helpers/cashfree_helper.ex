defmodule CoreWeb.Helpers.CashfreeHelper do
  #   Core.CashFree.Sages.Order

  @moduledoc false
  use CoreWeb, :core_helper
  alias Core.Payments
  alias CoreWeb.GraphQL.Resolvers.CashfreeResolver, as: CFResolver
  alias CoreWeb.Helpers.PaypalOrderHelper, as: PPOrderHelper
  alias CoreWeb.Utils.{CommonFunctions, HttpRequest}
  alias CoreWeb.Utils.HttpRequest

  def create_cashfree_order(params) do
    new()
    |> run(:verify_branch, &PPOrderHelper.verify_branch_on_subscription_purchase/2, &abort/3)
    |> run(:verify_item_amount, &PPOrderHelper.verify_transaction_amount_with_purpose/2, &abort/3)
    |> run(:altered_params, &PPOrderHelper.calculate_tips_and_donations/2, &abort/3)
    |> run(:verfy_payable_amount, &PPOrderHelper.verify_total_payable_amount/2, &abort/3)
    |> run(:local_transaction, &PPOrderHelper.create_local_transaction/2, &abort/3)
    |> run(:cashfree_order, &creating_cashfree_order/2, &abort/3)
    |> run(:updated_local_transaction, &update_local_transaction/2, &abort/3)
    |> run(:cashfree_order_payment, &cashfree_order_payment/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def cashfree_order_payment(%{cashfree_order: cashfree_order}, %{with_pay: true} = params) do
    params = Map.merge(params, %{order_token: cashfree_order.order_token})

    case cashfree_order_pay(params) do
      {:ok, _last, %{order_pay: order_pay}} -> {:ok, order_pay}
      {:error, error} -> {:error, error}
    end
  end

  def cashfree_order_payment(_, _), do: {:ok, "only order created"}

  def cashfree_order_pay(params) do
    new()
    |> run(:customer_validation, &PPOrderHelper.customer_validation/2, &abort/3)
    |> run(:local_transaction, &get_local_transaction/2, &abort/3)
    |> run(:update_purpose, &PPOrderHelper.update_purpose_for_paid/2, &abort/3)
    |> run(:make_cmr_payment_active, &make_local_payment_active_for_cmr/2, &abort/3)
    |> run(:update_balance, &update_balance/2, &abort/3)
    |> run(:order_pay, &cashfree_order_pay/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_payment_when_order_pay(params) do
    new()
    |> run(:cashfree_order, &get_cashfree_order/2, &abort/3)
    |> run(:update_local_details, &update_local_details/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # .................................................................................................
  defp get_local_transaction(_, %{order_id: trx_id}) do
    case Payments.get_payment_by_transaction_id(trx_id) do
      %{} = payment -> {:ok, payment}
      _ -> {:error, ["Local Payment against this Cashfree Transaction id does not exist"]}
    end
  end

  defp make_local_payment_active_for_cmr(%{local_transaction: local_transaction}, params) do
    cmr_payment_status_id =
      case params do
        %{cash_payment_id: _} -> nil
        %{promotion_pricing_id: _} -> nil
        %{subscription_feature_slug: _} -> nil
        _ -> "active"
      end

    case Payments.update_payment(
           local_transaction,
           %{cmr_payment_status_id: cmr_payment_status_id, paid_at: DateTime.utc_now()}
         ) do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  defp update_balance(
         %{
           local_transaction: %{
             tudo_total_amount: tudo_amount,
             branch_id: branch_id,
             total_transaction_amount: bsp_spent_amount
           }
         },
         _params
       ) do
    case Payments.get_balance_by_branch(branch_id) do
      nil ->
        attrs = %{
          tudo_balance: tudo_amount,
          branch_id: branch_id,
          bsp_spent_amount: bsp_spent_amount
        }

        case Payments.create_balance(attrs) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while creating balance"]}
        end

      %{tudo_balance: tudo_balance, bsp_spent_amount: current_bsp_spent_amount} = balance ->
        tudo_balance = round_off_value(tudo_balance + tudo_amount)

        bsp_spent_amount = round_off_value(current_bsp_spent_amount + bsp_spent_amount)

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

  # def verify_payment_method(params) do
  #   case params do
  #     %{payment_method: %{card: _card_details}} ->
  #       :ok

  #     %{payment_method: %{upi: _upi_id}} ->
  #       :ok

  #     %{payment_method: %{net_banking: net_ban}} ->
  #      :ok

  #     _ ->
  #       {:error, ["Invalid Params"]}
  #   end
  # end
  defp cashfree_order_pay(_, %{order_status: "PAID"}), do: {:ok, "Order already Paid"}

  defp cashfree_order_pay(_, %{} = params) do
    url = System.get_env("CASHFREE_ORDER_URL") <> "/pay"

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"x-api-version", System.get_env("CASHFREE_X_API_VERSION")}
    ]

    input = %{
      order_token: params.order_token,
      payment_method: params.payment_method,
      application_context: %{
        return_url: "https://tudo.app/pages/payments-success",
        cancel_url: "https://tudo.app/pages/payments-error"
      }
    }

    case HttpRequest.post(url, input, headers, hackney: [basic_auth: CFResolver.auth()]) do
      {:ok, data} -> {:ok, CommonFunctions.keys_to_atoms(data)}
      {:error, error} -> {:error, error}
    end
  end

  def cash_free_credentials do
    url = System.get_env("CASHFREE_ORDER_URL")

    %{
      url: url,
      headers: [
        {"Accept", "application/json"},
        {"Content-Type", "application/json"},
        {"x-api-version", System.get_env("CASHFREE_X_API_VERSION")},
        {"x-client-id", System.get_env("CASHFREE_X_CLIENT_ID")},
        {"x-client-secret", System.get_env("CASHFREE_X_CLIENT_SECRET")}
      ]
    }
  end

  def creating_cashfree_order(
        %{
          local_transaction: transaction,
          altered_params: %{amount: _, custom_fields: _}
        },
        %{country_id: _, amount: _} = params
      ) do
    cash_free_credentials = cash_free_credentials()

    input = %{
      customer_details: params.customer_details,
      order_amount: transaction.total_transaction_amount |> convert_amount_to_numeric,
      order_currency: "INR"
    }

    case HttpRequest.post(cash_free_credentials.url, input, cash_free_credentials.headers,
           hackney: [basic_auth: CFResolver.auth()]
         ) do
      {:ok, data} ->
        {:ok, CommonFunctions.keys_to_atoms(data)}

      {:error, error} ->
        {:error, error}
    end
  end

  # will use when we update the version cashfree API's
  # defp update_local_transaction(
  #        %{cashfree_order: %{order_token: transaction_id}, local_transaction: local_transaction},
  #        _
  #      ) do
  #   case Payments.update_payment(local_transaction, %{transaction_id: transaction_id}) do
  #     {:ok, transaction} -> {:ok, transaction}
  #     {:error, error} -> {:error, error}
  #   end
  # end

  defp update_local_transaction(
         %{cashfree_order: %{order_id: transaction_id}, local_transaction: local_transaction},
         _
       ) do
    case Payments.update_payment(local_transaction, %{transaction_id: transaction_id}) do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  def get_cashfree_order(_, %{order_id: order_id}) do
    cash_free_credentials = cash_free_credentials()

    url = cash_free_credentials.url <> "/" <> order_id

    case HttpRequest.get(url, cash_free_credentials.headers,
           hackney: [basic_auth: CFResolver.auth()]
         ) do
      {:ok, data} -> {:ok, CommonFunctions.keys_to_atoms(data)}
      {:error, error} -> {:error, error}
    end
  end

  def update_local_details(
        %{cashfree_order: %{order_status: order_status, order_id: order_id}},
        params
      ) do
    cond do
      order_status == "ACTIVE" ->
        {:ok, "No need to update when status is active"}

      order_status == "PAID" ->
        case cashfree_order_pay(
               Map.merge(params, %{order_status: order_status, order_id: order_id})
             ) do
          {:ok, _last, _all} -> {:ok, "local details updated"}
          data -> data
        end

      true ->
        {:error, "cannot update locally details with order status #{order_status}"}
    end
  end

  def convert_amount_to_numeric(amount) do
    amount_str = amount |> to_string()

    cond do
      String.contains?(amount_str, "e") ->
        :erlang.float_to_binary(amount, [:compact, {:decimals, 0}])
        |> :erlang.binary_to_integer()

      true ->
        amount
    end
  end
end
