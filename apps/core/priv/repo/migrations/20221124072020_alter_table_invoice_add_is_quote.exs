defmodule Core.Repo.Migrations.AlterTableInvoiceAddIsQuote do
  use Ecto.Migration

  @table "invoices"
  def change do
    alter table(@table) do
      add :is_quote, :boolean, default: false
    end
  end
end
