defmodule Core.Schemas.BrainTreeSubscription do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{Business, SubscriptionBSPRule, SubscriptionCMRRule, User}

  schema "brain_tree_subscriptions" do
    field :subscription_id, :string
    field :start_date, :date
    field :expiry_date, :date
    field :currency_symbol, :string
    field :status_id, :string
    belongs_to :subscription_bsp_rule, SubscriptionBSPRule
    belongs_to :subscription_cmr_rule, SubscriptionCMRRule
    belongs_to :user, User
    belongs_to :business, Business

    timestamps()
  end

  @doc false
  def changeset(brain_tree_subscription, attrs) do
    brain_tree_subscription
    |> cast(attrs, [
      :subscription_id,
      :user_id,
      :business_id,
      :subscription_bsp_rule_id,
      :subscription_cmr_rule_id,
      :status_id,
      :start_date,
      :expiry_date,
      :currency_symbol
    ])
    |> validate_required([:subscription_id, :business_id, :status_id, :start_date])
  end
end
