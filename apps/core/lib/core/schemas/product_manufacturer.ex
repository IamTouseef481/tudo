defmodule Core.Schemas.ProductManufacturer do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "product_manufacturers" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(product_manufacturers, attrs) do
    product_manufacturers
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
