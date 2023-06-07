defmodule CoreWeb.Helpers.HyperWalletUserHelper do
  #   Core.Payments.Sages.HyperWalletUser
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.Payments
  alias CoreWeb.Controllers.HyperWalletPaymentController

  def get_hyper_wallet_users(params) do
    new()
    |> run(:local_users, &get_local_users/2, &abort/3)
    |> run(:hw_users, &get_hyper_wallet_users/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_hyper_wallet_user(params) do
    new()
    #    |> run(:is_user_exists, &is_user_exists/2, &abort/3)
    |> run(:hw_user, &create_hp_user/2, &abort/3)
    |> run(:local_user, &create_local_user/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_hyper_wallet_user(params) do
    new()
    |> run(:local_user, &get_local_user/2, &abort/3)
    |> run(:hw_user, &update_hyper_wallet_user/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------

  #  defp is_user_exists(_, params) do
  #    case Payments.get_hyper_wallet_user_by(params) do
  #      []-> {:ok, ["user can be created"]}
  #      _data -> {:error, ["Hyperwallet User already exists!"]}
  #    end
  #  end

  defp get_local_user(_, params) do
    case Payments.get_hyper_wallet_user_by(params) do
      [] -> {:error, ["HyperWallet User doesn't exist"]}
      [data] -> {:ok, data}
      _data -> {:error, ["more than one records against this user"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to fetch hw local user"], __ENV__.line)
  end

  defp get_local_users(_, params) do
    case Payments.get_hyper_wallet_user_by(params) do
      [] -> {:error, ["HyperWallet User doesn't exist"]}
      users -> {:ok, users}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to fetch hw local user"], __ENV__.line)
  end

  defp create_hp_user(_, params) do
    url = "https://api.sandbox.hyperwallet.com/rest/v3/users"

    %{user_name: user_name, password: pass, program_token: token} =
      HyperWalletPaymentController.hyper_wallet_basic_authentication_for_user_creation()

    request_body =
      HyperWalletPaymentController.format_request_body(Map.merge(params, %{program_token: token}))

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(url, request_body, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} -> HyperWalletPaymentController.format_resulting_body(data.body)
      _ -> {:error, ["Unable to create Hyperwallet user!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  defp create_local_user(%{hw_user: %{token: user_token}}, %{user_id: user_id} = _params) do
    case Payments.create_hyper_wallet_user(%{user_token: user_token, user_id: user_id}) do
      {:ok, user} -> {:ok, user}
      {:error, _error} -> {:error, ["Unable to create Hyperwallet local user"]}
    end
  end

  defp update_hyper_wallet_user(%{local_user: %{user_token: token}}, input) do
    url = "https://api.sandbox.hyperwallet.com/rest/v3/users/#{token}"
    input = Map.delete(input, :user_id)

    %{user_name: user_name, password: pass, program_token: token} =
      HyperWalletPaymentController.hyper_wallet_basic_authentication_for_user_creation()

    request_body =
      HyperWalletPaymentController.format_request_body(Map.merge(input, %{program_token: token}))

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.put(url, request_body, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} -> HyperWalletPaymentController.format_resulting_body(data.body)
      _ -> {:error, ["Unable to update Hyperwallet user!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  defp get_hyper_wallet_users(%{local_users: users}, _) do
    user_accounts =
      Enum.map(users, fn %{user_token: token} = user ->
        case getting_hyper_wallet_user(token) do
          {:ok, hw_user} -> Map.merge(user, hw_user)
          _ -> user
        end
      end)

    {:ok, user_accounts}
  end

  defp getting_hyper_wallet_user(token) do
    url = "https://api.sandbox.hyperwallet.com/rest/v3/users/#{token}"

    %{user_name: user_name, password: pass, program_token: _token} =
      HyperWalletPaymentController.hyper_wallet_basic_authentication()

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.get(url, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} ->
        case HyperWalletPaymentController.format_resulting_body(data.body) do
          {:ok, data} -> {:ok, data}
          {:error, error} -> {:error, error}
        end

      _ ->
        {:error, ["Unable to get Hyperwallet user!"]}
    end
  end
end
