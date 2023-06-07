defmodule Core.Schemas.Balance do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "balances" do
    field :bsp_pending_balance, :float
    field :bsp_available_balance, :float
    field :bsp_cash_earning, :float
    field :bsp_annual_earning, :float
    field :bsp_total_earning, :float
    field :bsp_annual_transfer, :float
    field :bsp_total_transfer, :float
    field :tudo_balance, :float
    field :tudo_due_amount, :float
    field :cmr_spent_amount, :float
    field :bsp_spent_amount, :float
    field :currency_symbol, :string
    belongs_to :branch, Core.Schemas.Branch
    belongs_to :business, Core.Schemas.Business
    belongs_to :user, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(earning, attrs) do
    earning
    |> cast(attrs, [
      :bsp_pending_balance,
      :bsp_available_balance,
      :bsp_cash_earning,
      :bsp_annual_earning,
      :bsp_total_earning,
      :bsp_annual_transfer,
      :bsp_total_transfer,
      :cmr_spent_amount,
      :bsp_spent_amount,
      :tudo_balance,
      :tudo_due_amount,
      :branch_id,
      :business_id,
      :user_id,
      :currency_symbol
    ])

    #    |> validate_required([:branch_id])
  end
end
