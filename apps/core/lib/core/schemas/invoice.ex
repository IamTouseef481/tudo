defmodule Core.Schemas.Invoice do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field :job_id, :integer
    field :invoice_id, :string
    field :reference_no, :integer
    field :payment_type, :string
    field :discounts, {:array, :map}
    field :taxes, {:array, :map}
    field :amounts, {:array, :map}
    field :final_amount, :float
    field :total_charges, :float
    field :total_discount, :float
    field :total_tax, :float
    field :change, :boolean
    field :adjust, :boolean
    field :no_tax_concent, :boolean
    field :is_quote, :boolean, default: false
    field :adjust_reason, :string
    field :adjust_count, :integer
    field :rep, :string
    field :bill_to, :string
    field :comment, {:array, :string}
    belongs_to :business, Core.Schemas.Business
    belongs_to :order, Core.Schemas.Order

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :job_id,
      :invoice_id,
      :reference_no,
      :payment_type,
      :discounts,
      :taxes,
      :amounts,
      :final_amount,
      :total_charges,
      :total_discount,
      :total_tax,
      :adjust,
      :no_tax_concent,
      :adjust_reason,
      :adjust_count,
      :change,
      :comment,
      :rep,
      :bill_to,
      :business_id,
      :is_quote,
      :order_id
    ])

    # |> validate_required([:job_id])
  end
end
