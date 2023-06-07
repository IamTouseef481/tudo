defmodule Core.Repo.Migrations.CreateInvoices do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :job_id, :integer
      add :invoice_id, :string
      add :reference_no, :integer
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
      add :business_id, references(:businesses, on_delete: :nothing)

      timestamps()
    end

    create index(:invoices, [:business_id])
  end
end
