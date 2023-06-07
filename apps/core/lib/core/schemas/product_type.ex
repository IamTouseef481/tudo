defmodule Core.Schemas.ProductType do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "product_types" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(product_type, attrs) do
    product_type
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
