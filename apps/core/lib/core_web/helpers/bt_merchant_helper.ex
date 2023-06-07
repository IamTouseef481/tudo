defmodule CoreWeb.Helpers.BtMerchantHelper do
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.Payments

  #
  # Main actions
  #
  def get_brain_tree_merchant_account(params) do
    new()
    |> run(:merchant_account, &get_merchant_account/2, &abort/3)
    |> run(:bt_merchant_account, &get_bt_merchant_account/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_brain_tree_merchant_account(params) do
    new()
    #    |> run(:master_merchant, &get_master_merchant_account/2, &abort/3)
    #    |> run(:merchant_account, &get_merchant_account/2, &abort/3)
    |> run(:bt_merchant_account, &create_bt_merchant_account/2, &abort/3)
    |> run(:merchant_account, &create_merchant_account/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_brain_tree_merchant_account(params) do
    new()
    |> run(:merchant_account, &get_merchant_account/2, &abort/3)
    |> run(:bt_merchant_account, &update_bt_merchant_account/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  #   -----------------------------------------------

  defp get_merchant_account(_, params) do
    case Payments.get_brain_tree_merchant_by(params) do
      [] -> {:error, ["merchant account doesn't exist"]}
      [data] -> {:ok, data}
    end
  rescue
    _ -> {:error, ["Something went wrong, unable to fetch Merchant Account"]}
  end

  defp get_bt_merchant_account(_, %{merchant_account_id: id}) do
    case Braintree.Merchant.Account.find(id) do
      {:ok, merchant_account} ->
        merchant_account = str_to_map(merchant_account)
        {:ok, merchant_account}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Payment Gateway"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Something went wrong, unable to fetch Merchant Account"]}
    end
  end

  defp str_to_map(
         %{
           business: %{address: _b_address} = business,
           funding: _funding,
           individual: %{address: _i_address} = individual
         } = merchant_account
       ) do
    #   merchant_account = get_and_update_in(merchant_account, [:business, :address], &{&1, Map.from_struct(&1)})
    business =
      elem(
        Map.get_and_update(business, :address, fn b_address ->
          {b_address, Map.from_struct(b_address)}
        end),
        1
      )

    merchant_account = %{merchant_account | business: business}

    #   merchant_account = get_and_update_in(merchant_account, [:individual, :address], &{&1, &1})
    individual =
      elem(
        Map.get_and_update(individual, :address, fn i_address ->
          {i_address, Map.from_struct(i_address)}
        end),
        1
      )

    merchant_account = %{merchant_account | individual: individual}

    merchant_account =
      elem(
        Map.get_and_update(merchant_account, :business, fn business ->
          {business, Map.from_struct(business)}
        end),
        1
      )

    merchant_account =
      elem(
        Map.get_and_update(merchant_account, :funding, fn funding ->
          {funding, Map.from_struct(funding)}
        end),
        1
      )

    elem(
      Map.get_and_update(merchant_account, :individual, fn individual ->
        {individual, Map.from_struct(individual)}
      end),
      1
    )
  end

  defp create_bt_merchant_account(_, params) do
    params = Map.delete(params, :branch_id)
    params = Map.delete(params, :user_id)
    params = Map.delete(params, :primary)

    case Braintree.Merchant.Account.create(params) do
      {:ok, merchant} ->
        {:ok, merchant}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Payment Gateway"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Somethig went wrong, Merchant Account creation failed"]}
    end
  end

  #  TUDO: check already exist record
  defp create_merchant_account(
         %{merchant_account: %{id: id} = merchant},
         %{user_id: user_id, branch_id: branch_id, primary: primary}
       ) do
    Payments.create_brain_tree_merchant(%{
      merchant_account_id: id,
      user_id: user_id,
      branch_id: branch_id,
      primary: primary
    })

    {:ok, merchant}
  end

  defp update_bt_merchant_account(_, %{merchant_account_id: id} = params) do
    case Braintree.Merchant.Account.find(id) do
      {:ok, _merchant_account} ->
        params = Map.delete(params, :branch_id)
        params = Map.delete(params, :user_id)
        params = Map.delete(params, :primary)
        params = Map.delete(params, :merchant_account_id)
        merchant_account = Braintree.Merchant.Account.update(id, params)
        #        merchant_account = str_to_map(merchant_account)
        {:ok, merchant_account}

      {:error, :forbidden} ->
        {:error, ["Something went wrong with parameters for Braintree Payment Gateway"]}

      {:error, %{message: bt_error_message}} ->
        {:error, bt_error_message}

      _ ->
        {:error, ["Something went wrong, unable to fetch Merchant Account"]}
    end
  end
end
