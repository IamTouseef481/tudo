defmodule Core.Repo.Migrations.CreateCashPayments do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:cash_payments) do
      add :pay_due_amount, :float
      add :paid_amount, :float
      add :returned_amount, :float
      add :tudo_due_amount, :float
      add :adjust, :boolean, default: false, null: false
      add :adjust_reason, :string
      add :invoice_id, references(:invoices, on_delete: :nothing)

      timestamps()
    end

    create index(:cash_payments, [:invoice_id])
  end
end
