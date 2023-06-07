defmodule Core.Repo.Migrations.BiddingProposalQuotes do
  use Ecto.Migration

  def change do
    create table(:bidding_proposal_quotes) do
      add :invoice_id, :string
      add :payment_type, :string
      add :discounts, {:array, :map}
      add :taxes, {:array, :map}
      add :amounts, {:array, :map}
      add :final_amount, :float
      add :total_charges, :float
      add :total_discount, :float
      add :total_tax, :float
      add :adjust, :boolean
      add :adjust_reason, :string
      add :adjust_count, :integer, default: 0
      add :change, :boolean, default: false
      add :no_tax_concent, :boolean, default: true
      add :rep, :string
      add :bill_to, :string
      add :comment, {:array, :string}
      add :bid_proposal_id, references(:bid_proposals, on_delete: :nothing)
      add :business_id, references(:businesses, on_delete: :nothing)

      timestamps()
    end
  end
end
