defmodule Core.Products do
  @moduledoc """
  The Regions context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{Product, Branch, ProductCategory, Employee, Inventory, ProductCategoryItem}

  def list_products, do: Repo.all(Product)

  def list_product_category, do: Repo.all(ProductCategory)

  def get_product!(id), do: Repo.get!(Product, id)

  def get_product(id) do
    Product
    |> where([p], p.status == "active")
    |> Repo.get(id)
  end

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  def list_product(input) do
    query =
      Product
      |> join(:inner, [p], i in Inventory, on: p.id == i.product_id)
      |> where([p], p.status != "deleted")
      |> distinct([p], p.id)

    query =
      if Map.has_key?(input, :branch_id),
        do:
          query
          |> where(
            [p],
            p.branch_id == ^input.branch_id
          ),
        else: query

    query =
      if Map.has_key?(input, :name),
        do: query |> where([p], p.name == ^input.name),
        else: query

    query =
      if Map.has_key?(input, :purchase_uom),
        do:
          query
          |> where(
            [p],
            p.purchase_uom ==
              ^input.purchase_uom
          ),
        else: query

    query =
      if Map.has_key?(input, :sale_uom),
        do:
          query
          |> where(
            [p],
            p.sale_uom ==
              ^input.sale_uom
          ),
        else: query

    query =
      if Map.has_key?(input, :status),
        do:
          query
          |> where(
            [p],
            p.status ==
              ^input.status
          ),
        else: query

    Repo.all(query)
  end

  def check_owner(user_id, branch_id) do
    Branch
    |> join(:inner, [_b], e in Employee, on: e.branch_id == ^branch_id)
    |> where([_b, e], e.employee_role_id in ["branch_manager", "owner"])
    |> where([_b, e], e.employee_status_id == "active")
    |> where([_b, e], e.user_id == ^user_id)
    |> where([b, _e], b.status_id == "confirmed")
    |> Repo.exists?()
  end

  def get_product_category_item(category_item_id) do
    ProductCategoryItem
    |> where([p], p.id == ^category_item_id)
    |> Repo.one()
  end
end
