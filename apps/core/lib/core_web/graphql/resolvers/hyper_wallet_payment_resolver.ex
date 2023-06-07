defmodule CoreWeb.GraphQL.Resolvers.HyperWalletPaymentResolver do
  @moduledoc false
  alias CoreWeb.Controllers.HyperWalletPaymentController

  # list hyper wallet users
  def list_hyper_wallet_users(_, _, %{context: %{current_user: _current_user}}) do
    case HyperWalletPaymentController.list_hyper_wallet_users() do
      {:ok, data} ->
        {:ok, data}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["Unable to list down Hyperwallet users"]}
    end
  end

  # create hyper wallet user
  def create_hyper_wallet_user(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case HyperWalletPaymentController.create_hyper_wallet_user(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["unable to create hw user"]}
    end
  end

  # get hyper wallet user
  def get_hyper_wallet_users(_, _, %{context: %{current_user: current_user}}) do
    input = %{user_id: current_user.id}

    case HyperWalletPaymentController.get_hyper_wallet_users(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["unable to get hw user"]}
    end
  end

  # update hyper wallet user
  def update_hyper_wallet_user(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case HyperWalletPaymentController.update_hyper_wallet_user(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["unable to update hw user"]}
    end
  end

  # get hyper wallet currencies and transfer methods
  def get_hyper_wallet_currencies_and_transfer_methods(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case HyperWalletPaymentController.get_hyper_wallet_currencies_and_transfer_methods(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get hyper wallet transfer method fields
  def get_hyper_wallet_transfer_method_fields(_, %{input: input}, %{
        context: %{current_user: _current_user}
      }) do
    #    input = Map.merge(input, %{user_id: current_user.id, user: current_user})
    case HyperWalletPaymentController.get_hyper_wallet_transfer_method_fields(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # create hyper wallet transfer method
  def create_hyper_wallet_transfer_method(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case HyperWalletPaymentController.create_hyper_wallet_transfer_method(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # list all hyper wallet transfer methods
  def list_all_hyper_wallet_transfer_methods_of_user(_, _, %{
        context: %{current_user: current_user}
      }) do
    input = %{user_id: current_user.id}

    case HyperWalletPaymentController.list_all_hyper_wallet_transfer_methods_of_user(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get hyper wallet transfer method
  def get_hyper_wallet_transfer_method(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case HyperWalletPaymentController.get_hyper_wallet_transfer_method(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # update hyper wallet transfer method
  def update_hyper_wallet_transfer_method(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case HyperWalletPaymentController.update_hyper_wallet_transfer_method(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # list hyper wallet payments
  def list_hyper_wallet_payments(_, _, %{context: %{current_user: _current_user}}) do
    #    input = Map.merge(input, %{user_id: current_user.id, user: current_user})
    case HyperWalletPaymentController.list_hyper_wallet_payments() do
      {:ok, data} ->
        {:ok, data}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["unable to list down hw payments"]}
    end
  end

  # create hyper wallet payment
  def create_hyper_wallet_payment(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id, country_id: current_user.country_id})

    case HyperWalletPaymentController.create_hyper_wallet_payment(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get hyper wallet payment
  def get_hyper_wallet_payment(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case HyperWalletPaymentController.get_hyper_wallet_payment(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["unable to get hw payment"]}
    end
  end

  # create hyper wallet transfer
  def create_hyper_wallet_transfer(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case HyperWalletPaymentController.create_hyper_wallet_transfer(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
