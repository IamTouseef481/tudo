defmodule Core.Schemas.OrderItem do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    field :quantity, :integer

    belongs_to :order, Core.Schemas.Order
    belongs_to :product, Core.Schemas.Product

    timestamps()
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:order_id, :product_id, :quantity])
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:order_id)
  end
end
