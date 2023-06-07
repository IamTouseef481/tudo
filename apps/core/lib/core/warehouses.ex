defmodule Core.Warehouses do
  @moduledoc """
  The Warehouses context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.Warehouse
  alias Core.Schemas.Inventory

  def list_warehouses do
    Repo.all(Warehouse)
  end

  def get_inventory_by(%{product_id: product_id}),
    do: Repo.get_by(Inventory, product_id: product_id)

  def get_inventory_by(id), do: Repo.get_by(Inventory, id: id)

  def create_warehouse(attrs \\ %{}) do
    %Warehouse{}
    |> Warehouse.changeset(attrs)
    |> Repo.insert()
  end

  def create_inventory(attrs \\ %{}) do
    %Inventory{}
    |> Inventory.changeset(attrs)
    |> Repo.insert()
  end

  def update_warehouse(%Warehouse{} = warehouse, attrs) do
    warehouse
    |> Warehouse.changeset(attrs)
    |> Repo.update()
  end

  def update_inventory(%Inventory{} = inventory, attrs) do
    inventory
    |> Inventory.changeset(attrs)
    |> Repo.update()
  end

  def delete_warehouse(%Warehouse{} = warehouse) do
    Repo.delete(warehouse)
  end

  def delete_inventory(%Inventory{} = inventory) do
    Repo.delete(inventory)
  end
end
