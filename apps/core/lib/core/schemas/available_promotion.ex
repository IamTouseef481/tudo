defmodule Core.Schemas.AvailablePromotion do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "available_promotions" do
    field :additional, :boolean, default: false
    field :active, :boolean
    field :begin_at, :utc_datetime
    field :broadcast_range, :float
    field :expire_at, :utc_datetime
    field :price, :float
    field :title, :string
    field :used_at, :utc_datetime
    belongs_to :promotion_pricing, Core.Schemas.PromotionPurchasePrice
    belongs_to :branch, Core.Schemas.Branch
    belongs_to :business, Core.Schemas.Business

    timestamps()
  end

  @doc false
  def changeset(available_promotion, attrs) do
    available_promotion
    |> cast(attrs, [
      :title,
      :additional,
      :active,
      :price,
      :broadcast_range,
      :begin_at,
      :expire_at,
      :used_at,
      :branch_id,
      :business_id,
      :promotion_pricing_id
    ])
    |> validate_required([:additional, :broadcast_range, :begin_at, :expire_at])
  end
end
