defmodule Core.Schemas.AvailableSubscriptionFeature do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "available_subscription_features" do
    field :begin_at, :utc_datetime
    field :expire_at, :utc_datetime
    field :price, :float
    field :subscription_feature_slug, :string
    field :title, :string
    field :used_at, :utc_datetime
    field :active, :boolean, default: false
    belongs_to :branch, Core.Schemas.Branch

    timestamps()
  end

  @doc false
  def changeset(available_subscription_feature, attrs) do
    available_subscription_feature
    |> cast(attrs, [
      :title,
      :subscription_feature_slug,
      :price,
      :active,
      :begin_at,
      :expire_at,
      :used_at,
      :branch_id
    ])
    |> validate_required([:subscription_feature_slug, :price, :begin_at])
  end
end
