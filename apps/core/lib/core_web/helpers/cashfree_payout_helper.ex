defmodule CoreWeb.Helpers.CashfreePayoutHelper do
  #   Core.PaypalPayments.Sages.Payout
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{CashfreePayments}
  # alias Core.{TudoCharges}
  alias CoreWeb.Utils.HttpRequest
  alias CoreWeb.Helpers.PaypalPayoutHelper, as: PPH
  alias CoreWeb.Controllers.CashfreeController

  #
  # Main actions
  #
  def create_cashfree_payout(params) do
    new()
    |> run(:cashfree_beneficiary, &get_cashfree_beneficiary/2, &abort/3)
    |> run(:verify_min_max_transfer_limit, &PPH.verify_min_max_transfer_limit/2, &abort/3)
    |> run(:verify_payment_amount, &PPH.verify_payment_amount/2, &abort/3)
    |> run(:cashfree_payout, &create_cashfree_payout/2, &abort/3)
    |> run(:local_payment, &PPH.create_local_payment/2, &abort/3)
    |> run(:transfer_balance, &PPH.update_transfer_balance/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # ----------------create_cashfree_payout-------------------------------

  defp get_cashfree_beneficiary(_, %{user_id: _, bene_id: bene_id}) do
    case CashfreePayments.get_cashfree_beneficiary(bene_id) do
      nil -> {:error, ["cashfree beneficiary doesn't exist"]}
      %{} = data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to fetch seller"], __ENV__.line)
  end

  defp get_cashfree_beneficiary(_, %{user_id: user_id}) do
    case CashfreePayments.get_default_cashfree_beneficiary_account_by_user(user_id) do
      nil -> {:error, ["No Paypal account selected"]}
      %{} = data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to fetch default account"], __ENV__.line)
  end

  defp create_cashfree_payout(_, %{amount: amount, bene_id: bene_id, user_id: user_id} = params) do
    # paypal_fee =
    #   case TudoCharges.get_tudo_charges_by_slug("paypal_payout_fee", country_id) do
    #     %{value: value, is_percentage: is_percentage} ->
    #       if is_percentage, do: value / 100 * amount, else: value
    #     _ ->
    #       0
    #   end
    # amount = round_off_value(amount - paypal_fee)
    case CashfreeController.get_bearer_token_for_payout_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, token} ->
        url = System.get_env("CASHFREE_PAYOUT_URL")

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> token}
        ]

        input =
          %{
            "beneId" => bene_id,
            "amount" => amount,
            "transferId" =>
              (user_id |> to_string) <>
                "_" <> (System.os_time(:microsecond) |> to_string) <> "_tr"
          }
          |> make_params(params)

        case HttpRequest.post(url, input, headers, hackney: []) do
          {:ok, _data} -> {:ok, %{payout_id: input["transferId"]}}
          {:error, error} -> {:error, error}
        end
    end
  end

  def make_params(input, params) do
    Enum.reduce(params, %{}, fn
      {:transfer_mode, v}, acc -> Map.put(acc, "transferMode", v)
      {:payment_instrument_id, v}, acc -> Map.put(acc, "paymentInstrumentId", v)
      {:remarks, v}, acc -> Map.put(acc, "remarks", v)
      _, acc -> acc
    end)
    |> Map.merge(input)
  end
end
