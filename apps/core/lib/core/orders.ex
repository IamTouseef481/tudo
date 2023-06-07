defmodule Core.Orders do
  @moduledoc """
  The Regions context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{Order, OrderItem, OrderHistory, Product}

  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  def create_order_history(attrs \\ %{}) do
    %OrderHistory{}
    |> OrderHistory.changeset(attrs)
    |> Repo.insert()
  end

  def create_order_items(attrs \\ %{}) do
    %OrderItem{}
    |> OrderItem.changeset(attrs)
    |> Repo.insert()
  end

  def get_order!(id), do: Repo.get!(Order, id)
  def get_order(id), do: Repo.get(Order, id)

  def get_order_items_by(order_id) do
    OrderItem
    |> where([oi], oi.order_id == ^order_id)
    |> Repo.all()
  end

  def get_order_by(input) do
    query = Order |> where([o], o.user_id == ^input.user_id)

    query =
      if Map.has_key?(input, :chat_group_id),
        do:
          query
          |> where(
            [o],
            o.chat_group_id == ^input.chat_group_id
          ),
        else: query

    Repo.all(query)
  end

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def get_branch_of_product(order_id) do
    OrderItem
    |> join(:inner, [oi], p in Product, on: oi.product_id == p.id)
    |> where([oi], oi.order_id == ^order_id)
    |> select([_oi, p], p.branch_id)
    |> limit(1)
    |> Repo.one()
  end

  def get_order_by_product_id(product_id) do
    OrderItem
    |> join(:inner, [oi], p in Product, on: oi.product_id == p.id)
    |> join(:inner, [oi], o in Order, on: o.id == oi.order_id)
    |> where([_oi, p, _o], p.id == ^product_id)
    |> where([_oi, _p, o], o.status_id not in ["cancelled", "completed"])
    |> select([_oi, _p, o], o.status_id)
    |> Repo.all()
  end
end
