defmodule CoreWeb.Controllers.HyperWalletPaymentController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.Payments
  alias CoreWeb.Helpers.HyperWalletPaymentHelper, as: HyperWalletPayment
  alias CoreWeb.Helpers.HyperWalletTransferMethodHelper, as: HyperWalletTransferMethod
  alias CoreWeb.Helpers.HyperWalletUserHelper, as: HyperWalletUser

  def list_hyper_wallet_users do
    url = "https://api.sandbox.hyperwallet.com/rest/v3/users?limit=30"
    %{user_name: user_name, password: pass} = hyper_wallet_basic_authentication()

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.get(url, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} ->
        format_resulting_body(data.body)

      _all ->
        {:error, ["Unable to list down Hyperwallet users"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to list down Hyperwallet users"], __ENV__.line)
  end

  def create_hyper_wallet_user(input) do
    with {:ok, _last, all} <- HyperWalletUser.create_hyper_wallet_user(input),
         %{hw_user: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create Hyperwallet user"], __ENV__.line)
  end

  def get_hyper_wallet_users(input) do
    with {:ok, _last, all} <- HyperWalletUser.get_hyper_wallet_users(input),
         %{hw_users: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to get Hyperwallet users"], __ENV__.line)
  end

  def update_hyper_wallet_user(input) do
    with {:ok, _last, all} <- HyperWalletUser.update_hyper_wallet_user(input),
         %{hw_user: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to update Hyperwallet users"], __ENV__.line)
  end

  def list_all_hyper_wallet_transfer_methods_of_user(input) do
    with {:ok, _last, all} <-
           HyperWalletTransferMethod.list_all_hyper_wallet_transfer_methods_of_user(input),
         %{hw_transfer_methods: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Unable to list_all_hyper_wallet_transfer_methods_of_user"],
        __ENV__.line
      )
  end

  def create_hyper_wallet_transfer_method(input) do
    with {:ok, _last, all} <-
           HyperWalletTransferMethod.create_hyper_wallet_transfer_method(input),
         %{hw_transfer_method: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Unable to create_hyper_wallet_transfer_method "],
        __ENV__.line
      )
  end

  def get_hyper_wallet_transfer_method(input) do
    with {:ok, _last, all} <- HyperWalletTransferMethod.get_hyper_wallet_transfer_method(input),
         %{hw_transfer_method: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to get_hyper_wallet_transfer_method"], __ENV__.line)
  end

  def update_hyper_wallet_transfer_method(input) do
    with {:ok, _last, all} <-
           HyperWalletTransferMethod.update_hyper_wallet_transfer_method(input),
         %{hw_transfer_method: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Unable to update_hyper_wallet_transfer_method"],
        __ENV__.line
      )
  end

  def list_hyper_wallet_payments do
    url = "https://api.sandbox.hyperwallet.com/rest/v3/payments?limit=100"
    %{user_name: user_name, password: pass} = hyper_wallet_basic_authentication()

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.get(url, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} ->
        format_resulting_body(data.body)

      _ ->
        {:error, ["Something went wrong, unable to list Hyperwallet transactions!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to list_hyper_wallet_payments"], __ENV__.line)
  end

  def create_hyper_wallet_payment(input) do
    with {:ok, _last, all} <- HyperWalletPayment.create_hyper_wallet_payment(input),
         %{hw_payment: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create_hyper_wallet_payment"], __ENV__.line)
  end

  def get_hyper_wallet_payment(%{payment_token: _token} = input) do
    with {:ok, _last, all} <- HyperWalletPayment.get_hyper_wallet_payment(input),
         %{hw_payment: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to get_hyper_wallet_payment"], __ENV__.line)
  end

  def get_hyper_wallet_currencies_and_transfer_methods(%{user_id: _user_id} = input) do
    case Payments.get_hyper_wallet_user_by(input) do
      [] -> {:error, ["HyperWallet User doesn't exist"]}
      [user] -> get_currencies_and_transfer_methods(user.user_token, input)
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Unable to get_hyper_wallet_currencies_and_transfer_methods"],
        __ENV__.line
      )
  end

  def get_currencies_and_transfer_methods(token, %{country_iso2: country}) do
    url =
      "https://api.sandbox.hyperwallet.com/rest/v3/transfer-method-configurations?userToken=#{token}&limit=100"

    %{user_name: user_name, password: pass} = hyper_wallet_basic_authentication()

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.get(url, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} ->
        case format_resulting_body(data.body) do
          {:error, error} ->
            {:error, error}

          {:ok, data} ->
            body = get_more_countries_and_transfer_methods(token)
            all_records = data ++ body
            final_object = filter_currencies_and_transfer_types(all_records, country)
            {:ok, final_object}
        end

      {:error, %{reason: _reason}} ->
        {:error,
         [
           "Something went wrong, unable to retrieve Currencies and Transfer Method types due to request"
         ]}

      _ ->
        {:error,
         ["Connection intruption, unable to retrieve Currencies and Transfer Method types"]}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Error in fetching Currencies and Transfer Methods from Hyperwallet"],
        __ENV__.line
      )
  end

  def get_more_countries_and_transfer_methods(token) do
    url =
      "https://api.sandbox.hyperwallet.com/rest/v3/transfer-method-configurations?userToken=#{token}&limit=100&offset=100"

    %{user_name: user_name, password: pass} = hyper_wallet_basic_authentication()

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.get(url, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} ->
        case format_resulting_body(data.body) do
          {:error, error} -> {:error, error}
          {:ok, data} -> data
        end
    end
  end

  def filter_currencies_and_transfer_types(all_records, country) do
    all_records = Enum.map(all_records, &Map.drop(&1, [:fields, :links]))

    country_records =
      Enum.filter(all_records, fn currency ->
        if country in currency.countries do
          currency
        else
          false
        end
      end)

    currencies = Enum.reduce(country_records, [], &(&2 ++ &1.currencies))
    currencies = Enum.uniq(currencies)

    Enum.reduce(currencies, [], fn currency, currency_acc ->
      types =
        Enum.reduce(country_records, [], fn cr, type_acc ->
          if currency in cr.currencies do
            [cr.type | type_acc]
          else
            type_acc
          end
        end)

      types = Enum.uniq(types)
      [%{country: country, currency: currency, types: types} | currency_acc]
    end)
  end

  def get_hyper_wallet_transfer_method_fields(
        %{
          user_token: user_token,
          type: type,
          country: country,
          currency: currency,
          profile_type: profile_type
        } = _input
      ) do
    case get_transfer_method_from_type(type) do
      {:error, error} ->
        {:error, error}

      _method ->
        url = "https://api.sandbox.hyperwallet.com/rest/v3/transfer-method-configurations"
        url = url <> "?userToken=#{user_token}&country=#{country}&currency=#{currency}"
        url = url <> "&type=#{type}&profileType=#{profile_type}"
        %{user_name: user_name, password: pass} = hyper_wallet_basic_authentication()

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"}
        ]

        case HTTPoison.get(url, headers, hackney: [basic_auth: {user_name, pass}]) do
          {:ok, data} ->
            format_resulting_body(data.body)

          _ ->
            {:error, ["Something went wrong, unable to list Transfer Method fields!"]}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to list Transfer Method fields!"], __ENV__.line)
  end

  def get_hyper_wallet_transfer_method_fields(_params) do
    {:error, ["Some of the required parameters is missing!"]}
  end

  def create_hyper_wallet_transfer(input) do
    with {:ok, _last, all} <- HyperWalletPayment.create_hyper_wallet_transfer(input),
         %{hw_transfer: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to create_hyper_wallet_transfer"], __ENV__.line)
  end

  def hyper_wallet_basic_authentication_for_user_creation do
    %{
      user_name: "restapiuser@48045461612",
      password: "HydOffshore.123",
      # IS program token for creating user
      program_token: "prg-8bee45bc-21ee-42af-b48a-b688dc9b9a6e"
    }
  end

  def hyper_wallet_basic_authentication do
    %{
      user_name: "restapiuser@48045461612",
      password: "HydOffshore.123",
      # IM program token
      program_token: "prg-62d2c0dc-c26d-4590-8728-b2998004fe55"
    }
  end

  #  to get program
  #  def get_program(token) do
  #    url = "https://api.sandbox.hyperwallet.com/rest/v3/programs/#{token}"
  #    %{user_name: user_name, password: pass} = hyper_wallet_basic_authentication()
  #    headers = [
  #      {"Accept", "application/json"},
  #      {"Content-Type", "application/json"}
  #    ]
  #    case HTTPoison.get(url, headers, [hackney: [basic_auth: {user_name, pass}]]) do
  #      {:ok, data} ->
  #        format_resulting_body(data.body)
  #      _ -> {:error, ["Unable to create Hyperwallet payment!"]}
  #    end
  #  end

  def make_transfer_method_params(input) do
    case input do
      %{bank_account: bank_account} -> bank_account
      %{bank_card: bank_card} -> bank_card
      %{paypal_account: paypal_account} -> paypal_account
      %{venmo_account: venmo_account} -> venmo_account
      _ -> {:error, ["no transfer method to be updated"]}
    end
  end

  def get_transfer_method_from_type(type) do
    cond do
      type in ["BANK_ACCOUNT", "BANK_CARD", "PAYPAL_ACCOUNT", "VENMO_ACCOUNT", "PREPAID_CARD"] ->
        (String.downcase(type) <> "s") |> String.replace("_", "-")

      type in ["WIRE_ACCOUNT"] ->
        (String.downcase("BANK_ACCOUNT") <> "s") |> String.replace("_", "-")

      true ->
        {:error, ["Invalid Transfer Method type, check your input!"]}
    end
  end

  def format_request_body(attrs) do
    #    request_body = "{\"cardNumber\":\"4622943126011056\",\"cvv\":\"610\",\"dateOfExpiry\":\"2023-12\",
    #      \"transferMethodCountry\":\"US\",\"transferMethodCurrency\":\"USD\",\"type\":\"BANK_CARD\"}"

    attrs = snake_keys_to_camel(attrs)
    # map to string
    request_body = Enum.map_join(attrs, ",", fn {key, val} -> ~s{"#{key}":"#{val}"} end)
    # add "{" to start and "}" to end of string to make it as a proper key valued string
    "{" <> request_body <> "}"
  end

  def format_resulting_body(body) do
    if body == "" do
      {:ok, []}
    else
      case Poison.decode!(body) do
        %{"limit" => _a, "data" => body_list} ->
          reformat_resulting_body(body_list)

        body ->
          reformat_resulting_body(body)
      end
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, unable to retrieve Transfer Method against this Token and Type"],
        __ENV__.line
      )
  end

  def reformat_resulting_body(bodies) when is_list(bodies) do
    body =
      Enum.reduce(bodies, [], fn body, acc ->
        case reformat_resulting_body(body) do
          {:ok, body} -> [body | acc]
          _ -> acc
        end
      end)

    {:ok, body}
  end

  def reformat_resulting_body(body) do
    case body do
      %{"errors" => [%{"code" => error, "fieldName" => field, "message" => message}]} ->
        {:error, [error <> " (" <> field <> ")" <> ": " <> message]}

      %{"errors" => [%{"code" => error, "message" => message}]} ->
        {:error, [error <> ": " <> message]}

      %{"errors" => [%{"message" => message}]} ->
        {:error, [message]}

      %{"token" => _token} = body ->
        body = camel_keys_to_snake(body)
        {:ok, keys_to_atoms(body)}

      %{"fields" => _fields, "type" => _type} = body ->
        body = camel_keys_to_snake(body)
        {:ok, keys_to_atoms(body)}

      #        {:ok, body}

      _all ->
        {:error, ["error in reformatting results after decoding!"]}
    end
  end
end
