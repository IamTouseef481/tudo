defmodule Core.Schemas.Inventory do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "inventory" do
    field :bucket, :string
    field :quantity, :integer
    field :restoke_date, :utc_datetime

    belongs_to :product, Core.Schemas.Product

    timestamps()
  end

  @doc false
  def changeset(user_address, attrs) do
    user_address
    |> cast(attrs, [:bucket, :quantity, :restoke_date, :product_id])
  end
end
