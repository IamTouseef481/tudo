defmodule CoreWeb.GraphQL.Types.ProductType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :product_type do
    field(:id, :id)
    field(:branch_id, :integer)
    field(:name, :string)
    field(:description, :string)
    field(:category, :product_category_type, resolve: assoc(:category))
    field(:primary_product_id, :integer)
    field(:purchase_uom, :string)
    field(:purchase_price, :float)
    field(:sale_uom, :string)
    field(:sale_price, :float)
    field(:currency, :string)
    field(:product_image, list_of(:string))
    field(:thumb_nail, list_of(:string))
    field(:attribute, list_of(:json))
    field(:status, :string)
    field(:category_item, :category_item_type, resolve: assoc(:category_item))
    field(:inventory, :inventory_type, resolve: assoc(:inventory))
  end

  object :category_item_type do
    field :id, :string
    field :description, :string
  end

  object :product_category_type do
    field :id, :string
    field :description, :string
  end

  input_object :product_input_type do
    field(:branch_id, non_null(:integer))
    field(:name, non_null(:string))
    field(:description, :string)
    field(:category_id, non_null(:product_category_enum_type))
    field(:primary_product_id, :integer)
    field(:purchase_uom, :string)
    field(:purchase_price, :float)
    field(:sale_uom, non_null(:string))
    field(:sale_price, non_null(:float))
    field(:product_image, list_of(:string))
    field(:thumb_nail, list_of(:string))
    field(:attribute, list_of(:string))
    field(:status, non_null(:string))
    field(:category_item_id, non_null(:category_item_enum_type))
    field(:inventory, non_null(:create_inventory_input_type))
  end

  input_object :list_product_input_type do
    field(:branch_id, :integer)
    field(:name, :string)
    field(:purchase_uom, :string)
    field(:sale_uom, :string)
    field(:status, :string)
  end

  input_object :update_product_input_type do
    field(:id, non_null(:integer))
    field(:name, :string)
    field(:description, :string)
    field(:purchase_uom, :string)
    field(:purchase_price, :float)
    field(:sale_uom, :string)
    field(:sale_price, :float)
    field(:status, :string)
    field(:product_image, list_of(:string))
    field(:thumb_nail, list_of(:string))
    field(:category_item_id, :category_item_enum_type)
    field(:primary_product_id, :integer)
    field(:attribute, list_of(:string))
    field(:category_id, :integer)
    field(:inventory, :update_inventory_input_type)
  end

  input_object :delete_product_input_type do
    field(:id, :integer)
  end

  enum :category_item_enum_type do
    value(:product)
    value(:menu_item)
    value(:service_item)
    value(:event_reservation)
  end

  enum :product_category_enum_type do
    value(:finished_item)
    value(:sub_item)
    value(:add_on_item)
  end
end
