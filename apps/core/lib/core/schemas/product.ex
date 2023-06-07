defmodule Core.Schemas.Product do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Schemas.{Branch, ProductCategory, Product, ProductCategoryItem, Inventory}

  schema "products" do
    field :name, :string
    field :description, :string
    field :purchase_uom, :string
    field :purchase_price, :float
    field :sale_uom, :string
    field :sale_price, :float
    field :currency, :string
    field :product_image, {:array, :string}
    field :thumb_nail, {:array, :string}
    field :attribute, {:array, :map}
    field :status, :string

    belongs_to :branch, Branch
    belongs_to :category, ProductCategory, type: :string
    belongs_to :primary_product, Product
    belongs_to :category_item, ProductCategoryItem, type: :string
    has_one :inventory, Inventory

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :description,
      :purchase_uom,
      :purchase_price,
      :sale_uom,
      :sale_price,
      :currency,
      :product_image,
      :thumb_nail,
      :attribute,
      :status,
      :branch_id,
      :primary_product_id,
      :category_id,
      :category_item_id
    ])
    |> validate_required([
      :name,
      :category_id,
      :branch_id,
      :sale_uom,
      :sale_price,
      :status,
      :category_item_id
    ])
  end
end
