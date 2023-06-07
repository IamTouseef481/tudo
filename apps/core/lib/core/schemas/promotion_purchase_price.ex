defmodule Core.Schemas.PromotionPurchasePrice do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "promotion_purchase_price" do
    field :slug, :string
    field :base_price, :float
    field :broadcast_range, :integer
    field :discount_percentage, :float
    field :discounts, {:array, :map}
    field :promotion_cost, :float
    field :promotion_total_cost, :float
    field :tax_percentage, :float
    field :taxes, {:array, :map}
    field :currency_symbol, :string
    field :branch_id, :id

    timestamps()
  end

  @doc false
  def changeset(promotion_purchase_price, attrs) do
    promotion_purchase_price
    |> cast(attrs, [
      :slug,
      :base_price,
      :broadcast_range,
      :promotion_cost,
      :discounts,
      :discount_percentage,
      :taxes,
      :tax_percentage,
      :promotion_total_cost,
      :currency_symbol,
      :branch_id
    ])
    |> validate_required([
      :slug,
      :base_price,
      :broadcast_range,
      :promotion_cost,
      :promotion_total_cost,
      :branch_id
    ])
  end
end
