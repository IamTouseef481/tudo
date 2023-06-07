defmodule CoreWeb.GraphQL.Types.InventoryType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :inventory_type do
    field :id, :id
    field :bucket, :string
    field :quantity, :integer
    field :restoke_date, :datetime
    field :product, :product_type, resolve: assoc(:product)
  end

  input_object :create_inventory_input_type do
    field :bucket, :string
    field :quantity, :integer
    field :restoke_date, :datetime
  end

  input_object :update_inventory_input_type do
    field :bucket, :string
    field :quantity, :integer
    field :restoke_date, :datetime
  end
end
