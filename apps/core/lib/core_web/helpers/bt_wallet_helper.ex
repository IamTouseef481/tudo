defmodule CoreWeb.Helpers.BtWalletHelper do
  #   Core.Payments.Sages.Wallet
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.Payments

  def get_brain_tree_customer(params) do
    new()
    |> run(:wallet, &get_wallet/2, &abort/3)
    |> run(:methods, &get_payment_methods/2, &abort/3)
    |> run(:customer, &get_bt_customer/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_transaction_on_behalf_cmr(params) do
    new()
    |> run(:is_customer_exists, &is_customer_exists/2, &abort/3)
    |> run(:is_payment_method_exists, &is_payment_method_exists/2, &abort/3)
    |> run(:customer_and_payment_method, &create_bt_customer_and_payment_method/2, &abort/3)
    |> run(:proceed_to_transaction, &proceed_to_transaction/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_brain_tree_customer(params) do
    new()
    |> run(:is_customer_exists, &is_customer_exists/2, &abort/3)
    |> run(:customer, &create_bt_customer/2, &abort/3)
    |> run(:wallet, &create_wallet/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_brain_tree_customer(params) do
    new()
    |> run(:wallet, &get_wallet/2, &abort/3)
    |> run(:customer, &update_bt_customer/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def delete_brain_tree_customer(params) do
    new()
    |> run(:wallet, &get_wallet/2, &abort/3)
    |> run(:bt_customer, &get_bt_customer/2, &abort/3)
    |> run(:payment_methods, &delete_payment_methods/2, &abort/3)
    |> run(:local_customer, &delete_local_customer/2, &abort/3)
    |> run(:braintree_customer, &delete_bt_customer/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------

  def create_bt_customer_and_payment_method(
        %{is_customer_exists: [data], is_payment_method_exists: :can_proceed_to_transaction},
        _
      ),
      do: {:ok, data}

  def create_bt_customer_and_payment_method(
        %{is_customer_exists: [], is_payment_method_exists: :create_customer_and_payment_method},
        %{user: user} = params
      ) do
    params = %{
      email: user.email,
      phone: user.mobile,
      first_name: user.profile["first_name"],
      last_name: user.profile["last_name"],
      user: user,
      user_id: user.id,
      type_id: Map.get(params, :payment_method_id),
      credit_card: params.credit_card
    }

    case CoreWeb.Controllers.PaymentController.create_brain_tree_customer(params) do
      {:ok, data} -> {:ok, data}
      data -> data
    end
  end

  def create_bt_customer_and_payment_method(
        %{
          is_customer_exists: [_data],
          is_payment_method_exists: :create_customer_and_payment_method
        },
        %{user: user, payment_method_id: payment_method_id} = params
      ) do
    params = Map.merge(%{user_id: user.id, type_id: payment_method_id}, params.credit_card)

    case CoreWeb.Controllers.PaymentController.create_brain_tree_payment_method(params) do
      {:ok, data} -> {:ok, data}
      data -> data
    end
  end

  def proceed_to_transaction(_, %{credit_card: _} = params) do
    Map.drop(params, [:credit_card])
    |> CoreWeb.Controllers.PaymentController.create_brain_tree_transaction()
  end

  defp is_customer_exists(_, %{credit_card: _} = params) do
    case Payments.get_brain_tree_wallet_by(params) do
      [] -> {:ok, []}
      wallet -> {:ok, wallet}
    end
  end

  defp is_customer_exists(_, params) do
    case Payments.get_brain_tree_wallet_by(params) do
      [] -> {:ok, "customer can be created"}
      _ -> {:error, ["Braintree Customer account already exists!"]}
    end
  end

  def is_payment_method_exists(%{is_customer_exists: []}, _),
    do: {:ok, :create_customer_and_payment_method}

  def is_payment_method_exists(%{is_customer_exists: [%{id: id}]}, %{
        credit_card: %{number: card_number}
      }) do
    case Payments.get_brain_tree_payment_methods_by(id, card_number) do
      [%{card_number: card_number}] when not is_nil(card_number) ->
        {:ok, :can_proceed_to_transaction}

      _ ->
        {:ok, :create_customer_and_payment_method}
    end
  end

  defp get_wallet(_, params) do
    case Payments.get_brain_tree_wallet_by(params) do
      [] -> {:error, ["Braintree customer account doesn't exist"]}
      [data] -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch Customer"], __ENV__.line)
  end

  defp get_payment_methods(%{wallet: %{id: id}}, _params) do
    case Payments.get_brain_tree_payment_method_by_customer(id) do
      methods ->
        bt_methods =
          Enum.reduce(methods, [], fn %{usage_purpose: usage_purpose, token: token}, acc ->
            case Braintree.PaymentMethod.find(token) do
              {:ok, data} ->
                [Map.merge(data, %{usage_purpose: usage_purpose}) | acc]

              _ ->
                acc
            end
          end)

        {:ok, bt_methods}
    end
  end

  defp get_bt_customer(%{wallet: %{customer_id: customer_id}, methods: methods}, _params) do
    case Braintree.Customer.find(customer_id) do
      {:ok, customer} ->
        #        credit_cards = customer.credit_cards
        #        cards = Enum.map(credit_cards, fn credit_card ->
        #          Map.from_struct(credit_card) |> Map.drop([:__meta__ , :__struct__])
        #        end)
        methods =
          Enum.map(methods, fn method ->
            Map.from_struct(method) |> Map.drop([:__meta__, :__struct__])
          end)

        customer = Map.merge(customer, %{credit_cards: methods})

        {:ok, customer}

      {:error, _} ->
        {:error, ["Unable to fetch Braintree Customer"]}

      _ ->
        {:error, ["unexpected error occurred"]}
    end
  end

  defp get_bt_customer(%{wallet: %{customer_id: customer_id}}, _) do
    case Braintree.Customer.find(customer_id) do
      {:ok, customer} ->
        credit_cards = customer.credit_cards

        cards =
          Enum.map(credit_cards, fn credit_card ->
            Map.from_struct(credit_card) |> Map.drop([:__meta__, :__struct__])
          end)

        customer = Map.merge(customer, %{credit_cards: cards})

        {:ok, customer}

      {:error, _} ->
        {:error, ["Unable to fetch Braintree Customer"]}

      _ ->
        {:error, ["unexpected error occurred"]}
    end
  end

  defp create_bt_customer(_, params) do
    params = Map.drop(params, [:user_id, :user, :type_id])

    case Braintree.Customer.create(params) do
      {:ok, customer} -> {:ok, customer}
      {:error, _} -> {:error, ["unable to create brain tree customer"]}
    end
  end

  #  TUDO: check already exist record
  defp create_wallet(
         %{customer: %{id: customer_id, credit_cards: [credit_card]}},
         %{
           user_id: user_id,
           credit_card: _credit_card
         } = params
       ) do
    case Payments.create_brain_tree_wallet(%{customer_id: customer_id, user_id: user_id}) do
      {:ok, customer} ->
        Payments.create_brain_tree_payment_method(%{
          token: credit_card.token,
          is_default: true,
          usage_purpose: ["cmr"],
          type_id: Map.get(params, :type_id),
          customer_id: customer.id
        })

        {:ok, customer}

      {:error, _} ->
        {:error, ["unable to create customer"]}
    end
  end

  defp create_wallet(%{customer: %{id: customer_id}}, %{user_id: user_id}) do
    case Payments.create_brain_tree_wallet(%{customer_id: customer_id, user_id: user_id}) do
      {:ok, customer} -> {:ok, customer}
      {:error, _} -> {:error, ["unable to create customer"]}
    end
  end

  defp update_bt_customer(%{wallet: %{customer_id: customer_id}}, params) do
    params = Map.delete(params, :user_id)

    case Braintree.Customer.update(customer_id, params) do
      {:ok, customer} ->
        cards =
          Enum.map(customer.credit_cards, fn credit_card ->
            Map.from_struct(credit_card) |> Map.drop([:__meta__, :__struct__])
          end)

        customer = Map.merge(customer, %{credit_cards: cards})
        {:ok, customer}

      {:error, _} ->
        {:error, ["Unable to update Braintree Customer"]}
    end
  end

  defp delete_payment_methods(%{wallet: %{id: id}}, _) do
    case Payments.get_brain_tree_payment_method_by_customer(id) do
      [] ->
        {:ok, "no payment methods associated with that customer"}

      methods ->
        {Enum.each(methods, &Payments.delete_brain_tree_payment_method(&1)),
         "deleted successfully"}
    end
  end

  defp delete_local_customer(%{wallet: customer}, _) do
    case Payments.delete_brain_tree_wallet(customer) do
      {:ok, customer} -> {:ok, customer}
      {:error, _} -> {:error, ["unable to delete customer"]}
    end
  end

  defp delete_bt_customer(%{bt_customer: %{id: customer_id} = customer}, _) do
    case Braintree.Customer.delete(customer_id) do
      :ok -> {:ok, customer}
      {:error, _} -> {:error, ["Unable to delete Braintree customer"]}
    end
  end
end
