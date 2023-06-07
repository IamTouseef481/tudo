defmodule CoreWeb.Helpers.HyperWalletPaymentHelper do
  #   Core.Payments.Sages.HyperWalletPayment
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{BSP, Payments, Regions, TudoCharges}
  alias Core.Payments.TipsDonationsBspAmountsCalculator, as: AMC
  alias CoreWeb.Controllers.HyperWalletPaymentController

  def create_hyper_wallet_payment(params) do
    new()
    |> run(:local_user, &get_local_user/2, &abort/3)
    |> run(:local_transfer_method, &get_local_transfer_methods_by_user/2, &abort/3)
    |> run(:verify_min_max_transfer_limit, &verify_min_max_transfer_limit/2, &abort/3)
    |> run(:verify_payment_amount, &verify_payment_amount/2, &abort/3)
    |> run(:hw_payment, &create_hw_payment/2, &abort/3)
    |> run(:local_payment, &create_local_payment/2, &abort/3)
    |> run(:transfer_balance, &update_transfer_balance/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def get_hyper_wallet_payment(params) do
    new()
    #    |> run(:is_user_exists, &is_user_exists/2, &abort/3)
    |> run(:hw_payment, &get_hw_payment/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_hyper_wallet_transfer(params) do
    new()
    #    |> run(:is_user_exists, &is_user_exists/2, &abort/3)
    |> run(:hw_transfer, &create_hw_transfer/2, &abort/3)
    #    |> run(:local_transfer, &create_local_transfer/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------

  defp get_local_user(_, params) do
    case Payments.get_hyper_wallet_user_by(params) do
      [] -> {:error, ["HyperWallet User doesn't exist"]}
      [data] -> {:ok, data}
      _data -> {:error, ["more than one records against this user"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to fetch user"], __ENV__.line)
  end

  #  defp get_local_hw_transfer_method(%{local_user: %{id: hw_user_id}}, %{transfer_method_id: tm_id}=_params) do
  #    case Payments.get_hyper_wallet_transfer_method_by_id_and_user(hw_user_id, tm_id) do
  #      nil -> {:error, ["hyper wallet transfer method doesn't exist"]}
  #      %{} = data-> {:ok, data}
  #    end
  #  rescue
  #    _all -> {:error, ["unable to fetch hw transfer method"]}
  #  end

  defp get_local_transfer_methods_by_user(%{local_user: %{id: hw_user_id}}, _params) do
    case Payments.get_hyper_wallet_transfer_methods_by_hw_user(hw_user_id) do
      [] -> {:error, ["Hyper Wallet Transfer Method doesn't exist"]}
      data -> {:ok, data}
    end
  rescue
    _all -> {:error, ["unable to fetch hw transfer method"]}
  end

  defp verify_min_max_transfer_limit(_, %{amount: amount, branch_id: branch_id} = _params) do
    case BSP.get_branch!(branch_id) do
      nil ->
        {:error, ["branch doesn't exist"]}

      %{country_id: nil} ->
        case verify_min_transfer_limit(amount, 1) do
          {:ok, _} -> verify_max_transfer_limit(amount, branch_id, 1)
          {:error, error} -> {:error, error}
        end

      %{country_id: country_id} ->
        case verify_min_transfer_limit(amount, country_id) do
          {:ok, _} -> verify_max_transfer_limit(amount, branch_id, country_id)
          {:error, error} -> {:error, error}
        end

      _ ->
        {:error, ["error while getting branch"]}
    end
  end

  defp verify_min_transfer_limit(amount, country_id) do
    case TudoCharges.get_tudo_charges_by_slug("bsp_minimum_transfer_amount", country_id) do
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

    case TudoCharges.get_tudo_charges_by_slug("bsp_maximum_transfer_amount", country_id) do
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

  defp verify_payment_amount(_, %{amount: amount, branch_id: branch_id} = _params) do
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

  defp create_hw_payment(%{local_user: %{user_token: destination_user_token}}, params) do
    destination_token =
      case params do
        %{destination_token: destination_token} -> destination_token
        _ -> destination_user_token
      end

    params = Map.drop(params, [:country_id])
    url = "https://api.sandbox.hyperwallet.com/rest/v3/payments"

    %{user_name: user_name, password: pass, program_token: token} =
      HyperWalletPaymentController.hyper_wallet_basic_authentication()

    request_body =
      Map.merge(params, %{
        program_token: token,
        destination_token: destination_token,
        client_payment_id: "#{DateTime.to_unix(DateTime.utc_now(), :nanosecond)}"
      })
      |> HyperWalletPaymentController.format_request_body()

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(url, request_body, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} ->
        HyperWalletPaymentController.format_resulting_body(data.body)

      _ ->
        {:error, ["Unable to create Hyperwallet payment!"]}
    end
  end

  defp create_local_payment(
         %{hw_payment: %{token: payment_token} = _payment},
         %{amount: amount, branch_id: branch_id, user_id: user_id, country_id: country_id} =
           _params
       ) do
    hyper_wallet_fee =
      AMC.get_tudo_charges("hyperwallet_fee", amount, country_id)
      |> round_off_value()

    [currency, currency_symbol] =
      case Regions.get_country_by_branch(branch_id) do
        [%{currency_code: currency, currency_symbol: currency_symbol}] ->
          [currency, currency_symbol]

        _ ->
          [nil, nil]
      end

    attrs = %{
      payout_id: payment_token,
      branch_id: branch_id,
      amount: amount,
      user_id: user_id,
      payout_fee: hyper_wallet_fee,
      transfer_at: DateTime.utc_now(),
      currency: currency,
      currency_symbol: currency_symbol
    }

    case Payments.create_bsp_transfer(attrs) do
      {:ok, data} -> {:ok, data}
      {:error, _error} -> {:error, ["unable to create hw local payment"]}
    end
  end

  defp update_transfer_balance(_, %{amount: amount, branch_id: branch_id}) do
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

  defp get_hw_payment(_, %{payment_token: payment_token}) do
    url = "https://api.sandbox.hyperwallet.com/rest/v3/payments/#{payment_token}"

    %{user_name: user_name, password: pass, program_token: _token} =
      HyperWalletPaymentController.hyper_wallet_basic_authentication()

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.get(url, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} -> HyperWalletPaymentController.format_resulting_body(data.body)
      _ -> {:error, ["Unable to get Hyperwallet payment!"]}
    end
  end

  #  defp create_local_transfer(%{hw_transfer: %{token: payment_token, destination_amount: amount}=payment},
  #         %{user_id: user_id} = _params) do
  #    payment_params = %{payment_token: payment_token, user_id: user_id, payment_amount: amount}
  #    case Payments.create_hyper_wallet_payment(payment_params) do
  #      {:ok, _data} -> {:ok, payment}
  #      {:error, _error} -> {:error, ["unable to create payment"]}
  #    end
  #  end

  defp create_hw_transfer(_, params) do
    url = "https://api.sandbox.hyperwallet.com/rest/v3/transfers"

    %{user_name: user_name, password: pass, program_token: token} =
      HyperWalletPaymentController.hyper_wallet_basic_authentication()

    request_body =
      HyperWalletPaymentController.format_request_body(Map.merge(params, %{program_token: token}))

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(url, request_body, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} ->
        HyperWalletPaymentController.format_resulting_body(data.body)

      _ ->
        {:error, ["Unable to create Hyperwallet transfer!"]}
    end
  end
end
