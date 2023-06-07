defmodule Core.Repo.Migrations.CreateInvoiceHistory do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:invoice_history) do
      add :change, :boolean, default: false
      add :comment, :string
      add :discount_ids, {:array, :integer}
      add :tax_ids, {:array, :integer}
      add :amount, :map
      add :invoice_id, references(:invoices, on_delete: :nothing)

      timestamps()
    end

    create index(:invoice_history, [:invoice_id])
  end
end
