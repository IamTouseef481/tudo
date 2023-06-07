defmodule Core.Schemas.BiddingProposalQuote do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "bidding_proposal_quotes" do
    field :invoice_id, :string
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
    field :adjust_reason, :string
    field :adjust_count, :integer
    field :rep, :string
    field :bill_to, :string
    field :comment, {:array, :string}
    belongs_to :business, Core.Schemas.Business
    belongs_to :bid_proposal, Core.Schemas.BidProposal

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :invoice_id,
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
      :bid_proposal_id
    ])
  end
end
