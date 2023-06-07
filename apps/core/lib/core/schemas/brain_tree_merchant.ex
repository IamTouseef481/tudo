defmodule Core.Schemas.BrainTreeMerchant do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "brain_tree_merchants" do
    field :merchant_account_id, :string
    field :primary, :boolean, default: false
    belongs_to :user, Core.Schemas.User
    belongs_to :branch, Core.Schemas.Branch

    timestamps()
  end

  @doc false
  def changeset(brain_tree_merchant, attrs) do
    brain_tree_merchant
    |> cast(attrs, [:user_id, :branch_id, :merchant_account_id, :primary])
    |> validate_required([:merchant_account_id, :primary])
  end
end
