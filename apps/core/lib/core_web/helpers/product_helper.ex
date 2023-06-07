defmodule CoreWeb.Helpers.ProductHelper do
  @moduledoc false

  use CoreWeb, :core_helper
  alias Core.{Products, Warehouses, Orders}
  #
  # Main actions
  #

  def create_product(params) do
    new()
    |> run(:check_owner, &check_owner/2, &abort/3)
    |> run(:create_product, &create_product/2, &abort/3)
    |> run(:inventory, &create_inventory/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_product(params) do
    new()
    |> run(:product, &get_product/2, &abort/3)
    |> run(:check_owner, &check_owner/2, &abort/3)
    |> run(:inventory, &get_inventory/2, &abort/3)
    |> run(:update_product, &update_product/2, &abort/3)
    |> run(:update_inventory, &update_inventory/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def delete_product(params) do
    new()
    |> run(:product, &get_product/2, &abort/3)
    |> run(:check_owner, &check_owner/2, &abort/3)
    |> run(:order, &get_product_order/2, &abort/3)
    |> run(:inventory, &get_inventory/2, &abort/3)
    |> run(:delete_inventory, &delete_inventory/2, &abort/3)
    |> run(:delete_product, &delete_product/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def check_owner(%{product: %{branch_id: branch_id}}, params) do
    case Products.check_owner(params[:user_id], branch_id) do
      false -> {:error, ["You are not the owner of this product"]}
      data -> {:ok, data}
    end
  end

  def check_owner(_, params) do
    case Products.check_owner(params[:user_id], params[:branch_id]) do
      false -> {:error, ["You are not the owner of this product"]}
      data -> {:ok, data}
    end
  end

  def create_product(_, params) do
    case Products.create_product(params) do
      {:ok, data} -> {:ok, data}
      {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} -> {:error, "#{k} " <> "#{msg}"}
      _ -> {:error, ["Unable to create product"]}
    end
  end

  def create_inventory(%{create_product: %{id: id}}, %{inventory: inventory}) do
    params = Map.merge(inventory, %{product_id: id})

    case Warehouses.create_inventory(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def get_product(_, %{id: id}) do
    case Products.get_product(id) do
      nil ->
        {:error, ["No record foound"]}

      product ->
        {:ok, product}
    end
  end

  def get_product_order(_, %{id: product_id}) do
    case Orders.get_order_by_product_id(product_id) do
      [] ->
        {:ok, [:valid]}

      _ ->
        {:error,
         [
           "Can't delete product, There is some order against this product that needs to be completed first"
         ]}
    end
  end

  def get_inventory(_, params) do
    case Warehouses.get_inventory_by(%{product_id: params.id}) do
      nil ->
        {:error, ["No inventory found"]}

      inventory ->
        {:ok, inventory}
    end
  end

  def update_inventory(%{inventory: inventory}, %{inventory: for_update_inventory}) do
    case Warehouses.update_inventory(inventory, for_update_inventory) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def update_inventory(_, _), do: {:ok, ["No need to update"]}

  def update_product(%{product: product}, params) do
    params = Map.drop(params, [:user_id])

    case Products.update_product(product, params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def delete_product(%{product: product}, _) do
    case Products.update_product(product, %{status: "deleted"}) do
      {:ok, product} -> {:ok, product}
      _ -> {:error, ["Error in delete product"]}
    end
  end

  def delete_inventory(%{inventory: inventory}, _) do
    case Warehouses.delete_inventory(inventory) do
      {:ok, inventory} -> {:ok, inventory}
      _ -> {:error, ["Error in delete inventory"]}
    end
  end
end
