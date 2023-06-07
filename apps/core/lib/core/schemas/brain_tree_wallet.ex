defmodule Core.Schemas.BrainTreeWallet do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "brain_tree_wallets" do
    field :customer_id, :string
    belongs_to :user, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(brain_tree_wallet, attrs) do
    brain_tree_wallet
    |> cast(attrs, [:user_id, :customer_id])
    |> validate_required([:user_id, :customer_id])
  end
end
