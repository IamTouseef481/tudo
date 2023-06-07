defmodule CoreWeb.Helpers.HyperWalletTransferMethodHelper do
  #   Core.Payments.Sages.HyperWalletTransferMethod
  @moduledoc false

  use CoreWeb, :core_helper

  import CoreWeb.Utils.Errors
  alias Core.Payments
  alias CoreWeb.Controllers.HyperWalletPaymentController
  alias CoreWeb.Utils.CommonFunctions

  #
  # Main actions
  #

  def create_hyper_wallet_transfer_method(params) do
    new()
    |> run(:local_user, &get_local_user/2, &abort/3)
    |> run(:hw_transfer_method, &create_hyper_wallet_transfer_method/2, &abort/3)
    |> run(:hw_local_transfer_method, &create_hw_local_transfer_method/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_hyper_wallet_transfer_method(params) do
    new()
    |> run(:local_user, &get_local_user/2, &abort/3)
    |> run(:local_hw_transfer_method, &get_local_hw_transfer_method/2, &abort/3)
    |> run(:hw_transfer_method, &update_hw_transfer_method/2, &abort/3)
    |> run(:updated_local_hw_transfer_method, &update_local_hw_transfer_method/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def list_all_hyper_wallet_transfer_methods_of_user(params) do
    new()
    |> run(:local_user, &get_local_user/2, &abort/3)
    |> run(:local_hw_transfer_methods, &get_local_hw_transfer_methods/2, &abort/3)
    |> run(:hw_transfer_methods, &list_all_hyper_wallet_transfer_methods_of_user/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def get_hyper_wallet_transfer_method(params) do
    new()
    |> run(:local_user, &get_local_user/2, &abort/3)
    |> run(:local_hw_transfer_method, &get_local_hw_transfer_method/2, &abort/3)
    |> run(:hw_transfer_method, &get_hyper_wallet_transfer_method/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------

  defp get_local_user(_, params) do
    case Payments.get_hyper_wallet_user_by(params) do
      [] ->
        {:error, ["HyperWallet User doesn't exist"]}

      [data] ->
        {:ok, data}

      exception ->
        logger(__MODULE__, exception, ["More than one records against this user"], __ENV__.line)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch HW user"], __ENV__.line)
  end

  defp get_local_hw_transfer_methods(%{local_user: %{id: id}}, _params) do
    case Payments.get_hyper_wallet_transfer_methods_by_hw_user(id) do
      [] -> {:error, ["hyper wallet transfer method doesn't exist"]}
      data -> {:ok, data}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Unable to list HW transfer methods of that user"],
        __ENV__.line
      )
  end

  defp list_all_hyper_wallet_transfer_methods_of_user(
         %{local_user: %{user_token: token}, local_hw_transfer_methods: local_methods},
         _input
       ) do
    url = "https://api.sandbox.hyperwallet.com/rest/v3/users/#{token}/transfer-methods?limit=100"

    %{user_name: user_name, password: pass} =
      HyperWalletPaymentController.hyper_wallet_basic_authentication()

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.get(url, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} ->
        case HyperWalletPaymentController.format_resulting_body(data.body) do
          {:error, error} ->
            {:error, error}

          {:ok, methods} ->
            methods =
              Enum.reduce(local_methods, [], fn %{token: local_token} = local_method, acc1 ->
                Enum.reduce(methods, acc1, fn %{token: hw_token} = hw_method, acc2 ->
                  if hw_token == local_token do
                    [
                      Map.merge(hw_method, %{
                        id: local_method.id,
                        is_default: local_method.is_default
                      })
                      | acc2
                    ]
                  else
                    acc2
                  end
                end)
              end)

            {:ok, methods}
        end

      exception ->
        logger(
          __MODULE__,
          exception,
          ["Unable to list HW transfer methods of that user"],
          __ENV__.line
        )
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def create_hyper_wallet_transfer_method(
        %{local_user: %{user_token: user_token}},
        %{params: params, type: type} = input
      ) do
    case HyperWalletPaymentController.get_transfer_method_from_type(type) do
      {:error, error} ->
        {:error, error}

      transfer_method_type ->
        url =
          "https://api.sandbox.hyperwallet.com/rest/v3/users/#{user_token}/#{transfer_method_type}"

        params = CommonFunctions.string_to_map(params)

        params =
          case input do
            %{profile_type: profile_type} ->
              Map.merge(params, %{
                type: input.type,
                transfer_method_country: input.transfer_method_country,
                transfer_method_currency: input.transfer_method_currency,
                profile_type: profile_type
              })

            _data ->
              Map.merge(params, %{
                type: input.type,
                transfer_method_country: input.transfer_method_country,
                transfer_method_currency: input.transfer_method_currency
              })
          end

        create_hyper_wallet_specific_transfer_method(url, params, input)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def create_hyper_wallet_specific_transfer_method(url, attrs, _input) do
    #    request_body = URI.encode_query(attrs)  #for query

    %{user_name: user_name, password: pass, program_token: _token} =
      HyperWalletPaymentController.hyper_wallet_basic_authentication()

    request_body = HyperWalletPaymentController.format_request_body(attrs)

    #    request_body = "{\"addressLine1\":\"123 Main Street\",\"bankAccountId\":\"7861012345\",
    # \"bankAccountPurpose\":\"CHECKING\",\"bracnhId\":101089292,\"city\":\"Hometown\",\"country\":
    # \"US\",\"firstName\":\"Tudo\",\"lastName\":\"Test\",\"postalCode\":\"12345\",\"profileType\":
    # \"INDIVIDUAL\",\"stateProvince\":\"WA\",\"transferMethodCountry\":\"US\",\"transferMethodCurrency\
    # ":\"USD\",\"type\":\"BANK_ACCOUNT\"}"
    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(url, request_body, headers, hackney: [basic_auth: {user_name, pass}]) do
      {:ok, data} ->
        HyperWalletPaymentController.format_resulting_body(data.body)

      exception ->
        logger(
          __MODULE__,
          exception,
          ["Unable to create Hyper Wallet transfer method"],
          __ENV__.line
        )
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  defp create_hw_local_transfer_method(
         %{hw_transfer_method: %{token: token}, local_user: %{id: hw_user_id}},
         %{is_default: true, type: type}
       ) do
    Payments.get_hyper_wallet_transfer_methods_by_hw_user(hw_user_id)
    |> Enum.each(&Payments.update_hyper_wallet_transfer_method(&1, %{is_default: false}))

    attrs = %{token: token, hw_user_id: hw_user_id, is_default: true, type: type}

    case Payments.create_hyper_wallet_transfer_method(attrs) do
      {:ok, method} -> {:ok, method}
      {:error, _error} -> {:error, ["unable to create hw local transfer method"]}
    end
  end

  defp create_hw_local_transfer_method(
         %{hw_transfer_method: %{token: token}, local_user: %{id: hw_user_id}},
         params
       ) do
    attrs = %{token: token, hw_user_id: hw_user_id, type: params.type}

    case Payments.create_hyper_wallet_transfer_method(attrs) do
      {:ok, method} -> {:ok, method}
      {:error, _error} -> {:error, ["unable to create hw local transfer method"]}
    end
  end

  defp get_hyper_wallet_transfer_method(
         %{
           local_user: %{user_token: user_token},
           local_hw_transfer_method: %{type: type, token: transfer_method_token}
         },
         _
       ) do
    gets_hyper_wallet_transfer_method(%{
      user_token: user_token,
      type: type,
      token: transfer_method_token
    })
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def gets_hyper_wallet_transfer_method(
        %{user_token: user_token, type: type, token: transfer_method_token} = _attrs
      ) do
    case HyperWalletPaymentController.get_transfer_method_from_type(type) do
      {:error, error} ->
        {:error, error}

      method ->
        url =
          "https://api.sandbox.hyperwallet.com/rest/v3/users/#{user_token}/#{method}/#{transfer_method_token}"

        %{user_name: user_name, password: pass} =
          HyperWalletPaymentController.hyper_wallet_basic_authentication()

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"}
        ]

        case HTTPoison.get(url, headers, hackney: [basic_auth: {user_name, pass}]) do
          {:ok, data} ->
            HyperWalletPaymentController.format_resulting_body(data.body)

          exception ->
            logger(
              __MODULE__,
              exception,
              ["Unable to list HW transfer methods of that user"],
              __ENV__.line
            )
        end
    end
  end

  defp get_local_hw_transfer_method(
         %{local_user: %{id: hw_user_id}},
         %{transfer_method_id: tm_id} = _params
       ) do
    case Payments.get_hyper_wallet_transfer_method_by_id_and_user(hw_user_id, tm_id) do
      nil -> {:error, ["hyper wallet transfer method doesn't exist"]}
      %{} = data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch HW transfer method"], __ENV__.line)
  end

  def update_hw_transfer_method(
        %{
          local_user: %{user_token: user_token},
          local_hw_transfer_method: %{type: type, token: transfer_method_token}
        },
        %{params: params} = _input
      ) do
    #    request_body = case make_transfer_method_params(input) do
    #      {:error, error} -> {:error, error}
    #      params -> format_request_body(params)
    #    end
    params = CommonFunctions.string_to_map(params)
    request_body = HyperWalletPaymentController.format_request_body(params)

    case request_body do
      {:error, error} ->
        {:error, error}

      request_body ->
        case HyperWalletPaymentController.get_transfer_method_from_type(type) do
          {:error, error} ->
            {:error, error}

          method ->
            url =
              "https://api.sandbox.hyperwallet.com/rest/v3/users/#{user_token}/#{method}/#{transfer_method_token}"

            %{user_name: user_name, password: pass} =
              HyperWalletPaymentController.hyper_wallet_basic_authentication()

            headers = [
              {"Accept", "application/json"},
              {"Content-Type", "application/json"}
            ]

            case HTTPoison.put(url, request_body, headers,
                   hackney: [basic_auth: {user_name, pass}]
                 ) do
              {:ok, data} ->
                HyperWalletPaymentController.format_resulting_body(data.body)

              exception ->
                logger(__MODULE__, exception, ["Unable to "], __ENV__.line)
            end
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def update_hw_transfer_method(
        %{
          local_user: %{user_token: user_token},
          local_hw_transfer_method: %{type: type, token: transfer_method_token}
        },
        _input
      ) do
    attrs = %{user_token: user_token, type: type, token: transfer_method_token}
    gets_hyper_wallet_transfer_method(attrs)
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  #  defp get_local_transfer_methods_by_user(%{local_user: %{id: hw_user_id}}, _params) do
  #    case Payments.get_hyper_wallet_transfer_methods_by_hw_user(hw_user_id) do
  #      [] -> {:error, ["Hyper Wallet Transfer Method doesn't exist"]}
  #      data-> {:ok, data}
  #    end
  #  rescue
  #    _all -> {:error, ["unable to fetch hw transfer method"]}
  #  end

  defp update_local_hw_transfer_method(
         %{local_hw_transfer_method: %{hw_user_id: hw_user_id} = tm},
         params
       ) do
    case params do
      %{is_default: true} ->
        Payments.get_hyper_wallet_transfer_methods_by_hw_user(hw_user_id)
        |> Enum.each(&Payments.update_hyper_wallet_transfer_method(&1, %{is_default: false}))

        case Payments.update_hyper_wallet_transfer_method(tm, %{is_default: true}) do
          {:ok, method} ->
            {:ok, method}

          {:error, _error} ->
            {:error, ["error while updating hw local hyper wallet transfer method"]}
        end

      _ ->
        {:ok, tm}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to update HW local Transfer Method"], __ENV__.line)
  end
end
