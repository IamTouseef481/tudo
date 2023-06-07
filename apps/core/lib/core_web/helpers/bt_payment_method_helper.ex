defmodule CoreWeb.Helpers.BtPaymentMethodHelper do
  #   Core.Payments.Sages.PaymentMethod
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.Payments

  #
  # Main actions
  #
  def get_brain_tree_payment_method(params) do
    new()
    |> run(:wallet, &get_wallet/2, &abort/3)
    |> run(:payment_method, &get_payment_method/2, &abort/3)
    |> run(:bt_payment_method, &get_bt_payment_method/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def get_brain_tree_payment_methods_by_user(params) do
    new()
    |> run(:wallet, &get_wallet/2, &abort/3)
    |> run(:payment_methods, &get_payment_methods/2, &abort/3)
    |> run(:bt_payment_methods, &get_bt_payment_methods/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_brain_tree_payment_method(params) do
    new()
    |> run(:wallet, &get_wallet/2, &abort/3)
    #    |> run(:nonce, &get_bt_customer/2, &abort/3)
    |> run(:bt_payment_method, &create_bt_method/2, &abort/3)
    |> run(:payment_method, &create_payment_method/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_brain_tree_payment_method(params) do
    new()
    |> run(:wallet, &get_wallet/2, &abort/3)
    |> run(:get_payment_method, &get_payment_method/2, &abort/3)
    |> run(:bt_payment_method, &update_bt_payment_method/2, &abort/3)
    |> run(:payment_method, &update_payment_method/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def delete_brain_tree_payment_method(params) do
    new()
    |> run(:wallet, &get_wallet/2, &abort/3)
    |> run(:payment_method, &get_payment_method/2, &abort/3)
    |> run(:get_bt_payment_method, &get_bt_payment_method/2, &abort/3)
    |> run(:local_payment_method, &delete_local_payment_method/2, &abort/3)
    |> run(:bt_payment_method, &delete_bt_payment_method/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------

  defp get_wallet(_, params) do
    case Payments.get_brain_tree_wallet_by(params) do
      [] -> {:error, ["Braintree account doesn't exist"]}
      [data] -> {:ok, data}
    end
  rescue
    _ -> {:error, ["Unable to fetch Braintree Payment Gateway account"]}
  end

  defp get_payment_method(%{wallet: customer}, params) do
    params = Map.merge(params, %{customer_id: customer.id})

    case Payments.get_brain_tree_payment_method_by_token_and_customer(params) do
      nil -> {:error, ["payment method doesn't exist"]}
      %{} = data -> {:ok, data}
    end
  rescue
    _ -> {:error, ["Unable to fetch Payment method"]}
  end

  defp get_payment_methods(%{wallet: customer}, _params) do
    case Payments.get_brain_tree_payment_method_by(%{customer_id: customer.id}) do
      [] -> {:error, ["payment method doesn't exist"]}
      data -> {:ok, data}
    end
  rescue
    _ -> {:error, ["Unable to fetch Payment method"]}
  end

  defp get_bt_payment_methods(%{payment_methods: methods}, _params) do
    methods =
      Enum.reduce(methods, [], fn %{token: token} = method, acc ->
        case get_bt_payment_method("", %{token: token}) do
          {:ok, bt_method} ->
            method = Map.merge(method, bt_method)
            [method | acc]

          _ ->
            acc
        end
      end)

    {:ok, methods}
  end

  defp get_bt_payment_method(_, %{token: token}) do
    case Braintree.PaymentMethod.find(token) do
      {:ok, method} -> {:ok, method}
      {:error, _} -> {:error, ["unable to fetch payment method!"]}
    end
  end

  defp create_bt_method(%{wallet: customer}, %{options: opts} = params) do
    customer_id = customer.customer_id

    params =
      Map.merge(params, %{
        payment_method_nonce: Braintree.Testing.Nonces.transactable(),
        customer_id: customer_id
      })

    params = Map.drop(params, [:user_id, :type_id, :options, :usage_purpose])

    case Braintree.PaymentMethod.create(params, [opts]) do
      {:ok, method} -> {:ok, method}
      {:error, %{message: bt_error_message}} -> {:error, bt_error_message}
      _ -> {:error, ["Unable to create Braintree Payment method"]}
    end
  end

  defp create_bt_method(%{wallet: customer}, params) do
    customer_id = customer.customer_id

    params =
      Map.merge(params, %{
        payment_method_nonce: Braintree.Testing.Nonces.transactable(),
        customer_id: customer_id
      })

    params = Map.drop(params, [:user_id, :type_id, :usage_purpose])

    case Braintree.PaymentMethod.create(params) do
      {:ok, method} -> {:ok, method}
      {:error, %{message: bt_error_message}} -> {:error, bt_error_message}
      _ -> {:error, ["Unable to create Braintree Payment method"]}
    end
  end

  #  TUDO: check already exist record
  # create payment method for customer
  defp create_payment_method(%{wallet: %{id: id}, bt_payment_method: %{token: token}}, params) do
    params = Map.merge(params, %{token: token, customer_id: id})

    params =
      case params do
        %{options: %{make_default: true}} ->
          Payments.get_brain_tree_payment_method_by_customer(id)
          |> Enum.each(&Payments.update_brain_tree_payment_method(&1, %{is_default: false}))

          Map.merge(params, %{is_default: true, card_number: params[:number]})

        _ ->
          Map.merge(params, %{card_number: params[:number]})
      end

    case Payments.create_brain_tree_payment_method(params) do
      {:ok, data} ->
        {:ok, data}

      {:error, %Ecto.Changeset{errors: [card_number: {message, _}]}} ->
        {:error, "card number " <> message}

      {:error, _error} ->
        {:error, ["unable to create payment method!"]}
    end
  end

  #  #create payment method for merchant
  #  defp create_payment_method(%{bt_payment_method: %{token: token, customer_id: customer_id} = method}, %{user_id: user_id, branch_id: branch_id, type_id: type_id}=params) do
  #    case Payments.create_brain_tree_payment_method(%{token: token, user_id: user_id, type_id: type_id, customer_id: customer_id}) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, error} -> {:error, ["unable to create payment method!"]}
  #    end
  #  end

  defp update_bt_payment_method(%{get_payment_method: %{token: token}}, params) do
    params = Map.drop(params, [:user_id, :usage_purpose, :type_id, :token])

    case Braintree.PaymentMethod.update(token, params) do
      {:ok, method} -> {:ok, method}
      {:error, %{message: bt_error_message}} -> {:error, bt_error_message}
      _ -> {:error, ["Unable to update Braintree Payment method"]}
    end
  end

  defp update_payment_method(
         %{get_payment_method: %{customer_id: bt_customer_id} = method},
         params
       ) do
    params =
      case params do
        %{options: %{make_default: true}} ->
          Payments.get_brain_tree_payment_method_by_customer(bt_customer_id)
          |> Enum.each(&Payments.update_brain_tree_payment_method(&1, %{is_default: false}))

          Map.merge(params, %{is_default: true})

        _ ->
          params
      end

    case Payments.update_brain_tree_payment_method(method, params) do
      {:ok, data} -> {:ok, data}
      {:error, _error} -> {:error, ["Unable to update local Payment method"]}
    end
  end

  defp delete_local_payment_method(%{payment_method: method}, _) do
    case Payments.delete_brain_tree_payment_method(method) do
      {:ok, method} -> {:ok, method}
      {:error, _error} -> {:error, ["unable to delete payment method"]}
    end
  end

  defp delete_bt_payment_method(%{get_bt_payment_method: %{token: token} = method}, _) do
    case Braintree.PaymentMethod.delete(token) do
      :ok -> {:ok, method}
      {:error, %{message: bt_error_message}} -> {:error, bt_error_message}
      _ -> {:error, ["Unable to delete Braintree Payment method"]}
    end
  end
end
