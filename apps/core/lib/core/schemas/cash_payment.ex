defmodule Core.Schemas.CashPayment do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cash_payments" do
    field :adjust, :boolean, default: false
    field :adjust_reason, :string
    field :paid_amount, :float
    field :pay_due_amount, :float
    field :returned_amount, :float
    field :tudo_due_amount, :float
    belongs_to :invoice, Core.Schemas.Invoice

    timestamps()
  end

  @doc false
  def changeset(cash_payment, attrs) do
    cash_payment
    |> cast(attrs, [
      :pay_due_amount,
      :paid_amount,
      :returned_amount,
      :tudo_due_amount,
      :adjust,
      :adjust_reason,
      :invoice_id
    ])
    |> validate_required([:pay_due_amount, :invoice_id])
  end
end
