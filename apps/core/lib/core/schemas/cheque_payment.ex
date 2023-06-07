defmodule Core.Schemas.ChequePayment do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cheque_payments" do
    field :adjust, :boolean, default: false
    field :adjust_reason, :string
    field :bank_name, :string
    field :cheque_amount, :float
    field :cheque_image, {:array, :map}
    field :cheque_number, :integer
    field :date, :date
    field :in_favor_of_name, :string
    field :pay_due_amount, :float
    field :tudo_due_amount, :float
    field :signatory_name, :string
    belongs_to :invoice, Core.Schemas.Invoice

    timestamps()
  end

  @doc false
  def changeset(cheque_payment, attrs) do
    cheque_payment
    |> cast(attrs, [
      :pay_due_amount,
      :tudo_due_amount,
      :cheque_amount,
      :cheque_number,
      :bank_name,
      :cheque_image,
      :in_favor_of_name,
      :signatory_name,
      :date,
      :adjust,
      :adjust_reason,
      :invoice_id
    ])
    |> validate_required([:pay_due_amount, :invoice_id])
  end
end
