defmodule CoreWeb.Helpers.PaypalSellerHelper do
  #   Core.PaypalPayments.Sages.Seller
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.PaypalPayments
  alias CoreWeb.Controllers.PaypalPaymentController
  alias CoreWeb.Utils.HttpRequest

  @auth {"AefHWoqTjbKK2TpXgmkWikaOs_IWaOqXRJ3avB67_R3aU2xDp122DxeBhgczZXsLFwOr_vNrNa1C9ze0",
         "EDEEz9jURMcJ6NnDLf0YAWBuVoGsMA8CVr_dQudgGvV2l5IAiJPbOQJXV_AEN1zlXsqhgGUuNiGcWlp3"}

  def create_paypal_seller_account(params) do
    new()
    #    |> run(:get_seller_account, &is_seller_account_exist/2, &abort/3)
    |> run(:verify_user, &customer_validation/2, &abort/3)
    |> run(:paypal_seller_account, &create_paypal_seller_account/2, &abort/3)
    |> run(:local_seller_account, &create_local_seller_account/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def delete_paypal_seller_account(params) do
    new()
    |> run(:verify_user, &customer_validation/2, &abort/3)
    |> run(:get_paypal_seller_account, &get_seller_account/2, &abort/3)
    |> run(:local_seller_account, &delete_local_seller_account/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_paypal_seller_account(params) do
    new()
    |> run(:verify_user, &customer_validation/2, &abort/3)
    |> run(:get_paypal_seller_account, &get_seller_account/2, &abort/3)
    |> run(:local_seller_account, &update_local_seller_account/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  #
  #    def update_paypal_seller_account(params) do
  #    new()
  #    |> run(:local_seller_account, &get_local_seller_account/2, &abort/3)
  ##    |> run(:paypal_subscription_plan, &update_paypal_subscription_plan/2, &abort/3)
  #    |> run(:paypal_seller_account, &update_paypal_seller_account/2, &abort/3)
  #    |> transaction(Core.Repo, params)
  #  end

  def get_paypal_seller_accounts_by_user(params) do
    new()
    |> run(:local_seller_accounts, &get_paypal_seller_accounts_by_user/2, &abort/3)
    |> run(:paypal_seller_accounts, &get_paypal_seller_account/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # --------------------create_paypal_seller_account---------------------------

  #  defp is_seller_account_exist(_, %{user_id: user_id}) do
  #    case PaypalPayments.get_paypal_seller_by_user(user_id) do
  #      nil -> {:ok, ["valid"]}
  #      _ -> {:error, ["You already have PayPal Seller account"]}
  #    end
  #  end

  defp customer_validation(_, %{user: user, password: password}) do
    case Argon2.verify_pass(password, user.password_hash) do
      true -> {:ok, user}
      _ -> {:error, ["Invalid user password"]}
    end
  end

  defp customer_validation(_, %{user: user}), do: {:ok, user}

  defp create_paypal_seller_account(_, %{email: email, to_be_created: true} = params) do
    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token}} ->
        url = System.get_env("PAYPAL_SELLER_URL")

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token}
        ]

        input = Map.delete(params, :user_id) |> Map.merge(%{tracking_id: email})

        case HttpRequest.post(url, input, headers, hackney: [basic_auth: @auth]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
        end
    end
  end

  defp create_paypal_seller_account(_, _), do: {:ok, "not created"}

  defp create_local_seller_account(%{paypal_seller_account: seller}, params) do
    seller_id =
      case seller do
        %{links: [%{href: seller_url} | _]} -> String.split(seller_url, "/") |> List.last()
        _ -> nil
      end

    case PaypalPayments.create_paypal_seller(Map.merge(params, %{partner_referral_id: seller_id})) do
      {:ok, seller} -> {:ok, seller}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Unable to create local PayPal seller"]}
    end
  end

  # --------------------delete_paypal_seller_account---------------------------

  defp get_seller_account(_, params) do
    case PaypalPayments.get_paypal_seller_by(params) do
      nil -> {:error, ["You do not have PayPal Seller account"]}
      seller -> {:ok, seller}
    end
  end

  defp delete_local_seller_account(%{get_paypal_seller_account: seller}, _) do
    case PaypalPayments.delete_paypal_seller(seller) do
      {:ok, seller} -> {:ok, seller}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Unable to delete local PayPal seller"]}
    end
  end

  # --------------------update_paypal_seller_account---------------------------

  defp update_local_seller_account(%{get_paypal_seller_account: seller}, params) do
    case PaypalPayments.update_paypal_seller(seller, params) do
      {:ok, seller} -> {:ok, seller}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Unable to delete local PayPal seller"]}
    end
  end

  # --------------------get_paypal_seller_accounts_by_user----------------------

  defp get_paypal_seller_accounts_by_user(_, %{user_id: user_id}) do
    case PaypalPayments.get_paypal_seller_accounts_by_user(user_id) do
      [] -> {:error, ["local PayPal seller does not exist"]}
      sellers -> {:ok, sellers}
    end
  end

  defp get_paypal_seller_account(%{local_seller_accounts: local_accounts}, _) do
    accounts =
      Enum.map(local_accounts, fn
        %{partner_referral_id: nil} = account ->
          account

        %{partner_referral_id: token} = account ->
          case getting_paypal_seller_account(token) do
            {:ok, seller} -> Map.merge(account, seller)
            _ -> account
          end

        account ->
          account
      end)

    {:ok, accounts}
  end

  # ----------------------------------------------------------------------------

  defp getting_paypal_seller_account(token) do
    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token, partner_attribution_id: _paypal_partner_attribution_id}} ->
        url = System.get_env("PAYPAL_SELLER_URL") <> "/" <> token

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token}
        ]

        case HttpRequest.get(url, headers, hackney: [basic_auth: @auth]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
        end
    end
  end

  #  defp get_local_paypal_subscription_plan(_, %{id: plan_id}) do
  #    case PaypalPayments.get_paypal_subscription_plan(plan_id) do
  #      nil -> {:error, ["Local PayPal Plan does not exist"]}
  #      %{} = plan -> {:ok, plan}
  #    end
  #  end

  #  defp update_local_paypal_subscription_plan(%{get_local_plan: plan}, params) do
  #    case PaypalPayments.update_paypal_subscription_plan(plan, params) do
  #      {:ok, plan} -> {:ok, plan}
  #      {:error, error} -> {:error, error}
  #      _ -> {:error, ["Unable to update local PayPal plan"]}
  #    end
  #  end
end
