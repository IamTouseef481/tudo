defmodule Core.Schemas.Promotion do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  alias Core.Schemas.{Branch, Dropdown, PromotionPurchasePrice, PromotionStatuses}

  schema "promotions" do
    field :title, :string
    field :description, :string
    field :photos, {:array, :map}
    field :begin_date, :utc_datetime
    field :end_date, :utc_datetime
    field :expiry_count, :integer
    field :max_user_count, :integer
    field :expire_after_amount, :float
    field :valid_after_amount, :float
    field :value, :float
    field :is_percentage, :boolean, default: true
    field :favourite, :boolean, default: false
    field :is_combined, :boolean, default: true
    field :service_ids, {:array, :integer}
    field :radius, :float, default: 0.0
    field :shareable_link, :string
    field :zone_ids, {:array, :integer}
    field :term_and_condition_ids, {:array, :integer}
    belongs_to :discount_type, Dropdown
    belongs_to :branch, Branch
    belongs_to :promotion_status, PromotionStatuses, type: :string
    belongs_to :promotion_pricing, PromotionPurchasePrice

    timestamps()
  end

  @doc false
  def changeset(promotion, attrs) do
    promotion
    |> cast(attrs, [
      :title,
      :description,
      :photos,
      :begin_date,
      :end_date,
      :expiry_count,
      :max_user_count,
      :expire_after_amount,
      :valid_after_amount,
      :value,
      :is_percentage,
      :is_combined,
      :service_ids,
      :radius,
      :shareable_link,
      :zone_ids,
      :term_and_condition_ids,
      :discount_type_id,
      :promotion_status_id,
      :branch_id,
      :promotion_pricing_id,
      :favourite
    ])
    |> validate_required([
      :title,
      :photos,
      :begin_date,
      :value,
      :is_combined,
      :service_ids,
      :zone_ids,
      :term_and_condition_ids,
      :discount_type_id,
      :promotion_status_id,
      :is_percentage
    ])
  end

  def update_promotion_status_changeset(promotion, attrs) do
    promotion
    |> cast(attrs, [
      :title,
      :description,
      :photos,
      :begin_date,
      :end_date,
      :expiry_count,
      :max_user_count,
      :expire_after_amount,
      :valid_after_amount,
      :value,
      :is_percentage,
      :is_combined,
      :radius,
      :service_ids,
      :zone_ids,
      :term_and_condition_ids,
      :discount_type_id,
      :promotion_status_id,
      :branch_id
    ])
    |> validate_required([:promotion_status_id])
  end
end
