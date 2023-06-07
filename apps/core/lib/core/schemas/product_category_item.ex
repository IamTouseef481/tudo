defmodule Core.Schemas.ProductCategoryItem do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "product_category_items" do
    field :id, :string, primary_key: true
    field :description, :string
    field :est_delivery_sec, :string
  end

  @doc false
  def changeset(product_category_items, attrs) do
    product_category_items
    |> cast(attrs, [:id, :description, :est_delivery_sec])
    |> validate_required([:id])
  end
end
