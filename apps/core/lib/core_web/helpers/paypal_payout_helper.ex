defmodule CoreWeb.Helpers.PaypalPayoutHelper do
  #   Core.PaypalPayments.Sages.Payout
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{Payments, PaypalPayments}
  alias CoreWeb.Controllers.PaypalPaymentController
  alias Core.{BSP, Regions, TudoCharges}
  alias Core.Payments.TipsDonationsBspAmountsCalculator, as: AMC
  alias CoreWeb.GraphQL.Resolvers.PaypalPaymentResolver, as: R
  alias CoreWeb.Utils.HttpRequest

  #
  # Main actions
  #
  def create_paypal_payout(params) do
    new()
    |> run(:paypal_seller, &get_paypal_seller/2, &abort/3)
    |> run(:verify_min_max_transfer_limit, &verify_min_max_transfer_limit/2, &abort/3)
    |> run(:verify_payment_amount, &verify_payment_amount/2, &abort/3)
    |> run(:paypal_payout, &create_paypal_payout/2, &abort/3)
    |> run(:local_payment, &create_local_payment/2, &abort/3)
    |> run(:transfer_balance, &update_transfer_balance/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def get_paypal_payout(params) do
    new()
    #    |> run(:is_user_exists, &is_user_exists/2, &abort/3)
    |> run(:paypal_payout, &get_paypal_payout/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # ----------------create_paypal_payout-------------------------------

  defp get_paypal_seller(_, %{user_id: _, seller_id: seller_id} = params) do
    case PaypalPayments.get_paypal_seller_by(Map.merge(params, %{id: seller_id})) do
      nil -> {:error, ["Paypal seller doesn't exist"]}
      %{} = data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to fetch seller"], __ENV__.line)
  end

  defp get_paypal_seller(_, %{user_id: user_id}) do
    case PaypalPayments.get_default_paypal_seller_account_by_user(user_id) do
      nil -> {:error, ["No Paypal account selected"]}
      %{} = data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to fetch default account"], __ENV__.line)
  end

  def verify_min_max_transfer_limit(_, %{amount: amount, branch_id: branch_id} = _params) do
    case BSP.get_branch!(branch_id) do
      nil ->
        {:error, ["branch doesn't exist"]}

      %{country_id: nil} ->
        case verify_min_transfer_limit(amount, 1, branch_id) do
          {:ok, _} -> verify_max_transfer_limit(amount, branch_id, 1)
          {:error, error} -> {:error, error}
        end

      %{country_id: country_id} ->
        case verify_min_transfer_limit(amount, country_id, branch_id) do
          {:ok, _} -> verify_max_transfer_limit(amount, branch_id, country_id)
          {:error, error} -> {:error, error}
        end

      _ ->
        {:error, ["error while getting branch"]}
    end
  end

  def verify_payment_amount(_, %{amount: amount, branch_id: branch_id} = _params) do
    case Payments.get_balance_by_branch(branch_id) do
      %{bsp_available_balance: max_available_balance} = balance ->
        if amount <= max_available_balance do
          case Payments.update_balance(balance, %{
                 bsp_available_balance: max_available_balance - amount
               }) do
            {:ok, balance} -> {:ok, balance}
            _ -> {:error, ["error in updating available balance"]}
          end
        else
          {:error, ["insufficient balance"]}
        end

      _ ->
        {:error, ["Error in fetching Available Balance"]}
    end
  end

  defp create_paypal_payout(
         %{paypal_seller: %{email: receiver_email}},
         %{
           amount: amount,
           country_id: country_id
         } = params
       ) do
    logger(__MODULE__, receiver_email, :info, __ENV__.line)

    paypal_fee =
      case TudoCharges.get_tudo_charges_by_slug(
             "paypal_payout_fee",
             country_id,
             params[:branch_id]
           ) do
        %{value: value, is_percentage: is_percentage} ->
          if is_percentage, do: value / 100 * amount, else: value

        _ ->
          0
      end

    amount = round_off_value(amount - paypal_fee)

    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
        #        paypal_partner_attribution_id = "FLAVORsb-cxm47s5549184_MP"
        url = System.get_env("PAYPAL_PAYOUT_URL")

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token},
          {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id}
        ]

        currency_code =
          case Core.Regions.get_countries(country_id) do
            #      %{currency_code: currency_code} -> currency_code    #some currencies are not acceptable like PKR, INR
            _ -> "USD"
          end

        input = %{
          sender_batch_header: %{
            sender_batch_id: "#{DateTime.to_unix(DateTime.utc_now(), :nanosecond)}",
            email_subject: "You have a payout!",
            email_message: "You have received a payout! Thanks for using our service!"
          },
          items: [
            %{
              recipient_type: "EMAIL",
              receiver: receiver_email,
              amount: %{value: amount, currency: currency_code},
              sender_item_id: "#{DateTime.to_unix(DateTime.utc_now(), :nanosecond)}"
            }
          ]
        }

        #    input = Map.drop(input, [:amount, :currency_code, :access_token])
        #            |> Map.merge(input)
        case HttpRequest.post(url, input, headers, hackney: [basic_auth: R.auth()]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
        end
    end
  end

  def create_local_payment(
        payment,
        %{amount: amount, branch_id: branch_id, user_id: user_id, country_id: country_id} =
          _params
      ) do
    paypal_fee =
      AMC.get_tudo_charges("paypal_fee", amount, country_id)
      |> round_off_value()

    [currency, currency_symbol] =
      case Regions.get_country_by_branch(branch_id) do
        [%{currency_code: currency, currency_symbol: currency_symbol}] ->
          [currency, currency_symbol]

        _ ->
          [nil, nil]
      end

    attrs =
      %{
        branch_id: branch_id,
        amount: amount,
        user_id: user_id,
        payout_fee: paypal_fee,
        transfer_at: DateTime.utc_now(),
        currency: currency,
        currency_symbol: currency_symbol
      }
      |> make_attrs(payment)

    case Payments.create_bsp_transfer(attrs) do
      {:ok, data} -> {:ok, data}
      {:error, _error} -> {:error, ["unable to create local transfer"]}
    end
  end

  def make_attrs(attrs, payment) do
    cond do
      Map.has_key?(payment, :paypal_payout) ->
        %{paypal_payout: %{batch_header: %{payout_batch_id: paypal_payout_id}}} = payment
        %{payout_gateway: "paypal", payout_id: paypal_payout_id}

      Map.has_key?(payment, :cashfree_payout) ->
        %{cashfree_payout: %{payout_id: payout_id}} = payment
        %{payout_gateway: "cashfree", payout_id: payout_id}
    end
    |> Map.merge(attrs)
  end

  def update_transfer_balance(_, %{amount: amount, branch_id: branch_id}) do
    case Payments.get_balance_by_branch(branch_id) do
      %{bsp_annual_transfer: annual_transfer, bsp_total_transfer: total_transfer} = balance ->
        annual_transfer = round_off_value(annual_transfer + amount)
        total_transfer = round_off_value(total_transfer + amount)

        case Payments.update_balance(balance, %{
               bsp_annual_transfer: annual_transfer,
               bsp_total_transfer: total_transfer
             }) do
          {:ok, data} -> {:ok, data}
          {:error, _error} -> {:error, ["error while updating balance"]}
        end

      _ ->
        {:error, ["error while getting balance"]}
    end
  end

  # ----------------get_paypal_payout-------------------------------

  defp get_paypal_payout(_, %{id: id}) do
    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
        url = System.get_env("PAYPAL_PAYOUT_URL") <> "/" <> id

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token},
          {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id}
        ]

        #    input = Map.drop(input, [:amount, :currency_code, :access_token])
        #            |> Map.merge(input)
        case HttpRequest.get(url, headers, hackney: [basic_auth: R.auth()]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
        end
    end
  end

  # ----------------get_paypal_payout-------------------------------

  defp verify_min_transfer_limit(amount, country_id, branch_id) do
    case TudoCharges.get_tudo_charges_by_slug(
           "bsp_minimum_transfer_amount",
           country_id,
           branch_id
         ) do
      %{value: min_transfer_amount} ->
        if amount >= min_transfer_amount do
          {:ok, ["valid amount"]}
        else
          {:error, ["Amount must be at least #{min_transfer_amount}"]}
        end

      _ ->
        {:error, ["Unable to get Service Provider minimum Transfer Limit"]}
    end
  end

  defp verify_max_transfer_limit(amount, branch_id, country_id) do
    today_transfer =
      case Payments.get_today_total_bsp_transfer_by_branch(branch_id) do
        nil -> 0
        amount -> amount
      end

    amount = amount + today_transfer

    case TudoCharges.get_tudo_charges_by_slug(
           "bsp_maximum_transfer_amount",
           country_id,
           branch_id
         ) do
      %{value: max_transfer_amount} ->
        remaining_transfer_limit = max_transfer_amount - today_transfer

        if amount <= max_transfer_amount do
          {:ok, ["valid amount"]}
        else
          {:error,
           [
             "MAX transfer limit is #{max_transfer_amount}, Today's remaining limit is #{remaining_transfer_limit}"
           ]}
        end

      _ ->
        {:error, ["Unable to get Service Provider maximum Transfer Limit"]}
    end
  end
end
