defmodule Core.Schemas.BSPTransfer do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "bsp_transfers" do
    field :amount, :float
    field :payout_fee, :float
    field :payout_id, :string
    field :currency, :string
    field :currency_symbol, :string
    field :transfer_at, :utc_datetime
    field :payout_gateway, :string
    belongs_to :branch, Core.Schemas.Branch
    belongs_to :user, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(bsp_transfer, attrs) do
    bsp_transfer
    |> cast(attrs, [
      :amount,
      :payout_fee,
      :payout_id,
      :currency_symbol,
      :currency,
      :transfer_at,
      :branch_id,
      :user_id,
      :payout_gateway
    ])
    |> validate_required([:amount, :branch_id, :payout_gateway])
  end
end
