defmodule Core.Repo.Migrations.AlterTableInvoicesAddOrderId do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :order_id, references(:orders, on_delete: :nothing)
    end
  end
end
