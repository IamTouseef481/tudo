defmodule Core.Schemas.ProductCategory do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "product_categories" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(product_category, attrs) do
    product_category
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
