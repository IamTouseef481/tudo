defmodule Core.Schemas.BrainTreePaymentMethod do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{BrainTreeMerchant, BrainTreeWallet}

  schema "brain_tree_payment_methods" do
    field :token, :string
    field :is_default, :boolean
    field :type_id, :string
    field :card_number, :string
    field :usage_purpose, {:array, :string}
    belongs_to :customer, BrainTreeWallet
    belongs_to :merchant, BrainTreeMerchant

    timestamps()
  end

  @doc false
  def changeset(brain_tree_payment_method, attrs) do
    brain_tree_payment_method
    |> cast(attrs, [
      :token,
      :type_id,
      :is_default,
      :customer_id,
      :merchant_id,
      :usage_purpose,
      :card_number
    ])
    |> unique_constraint([:card_number])
    |> validate_required([:token, :type_id])
  end
end
