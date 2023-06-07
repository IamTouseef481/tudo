defmodule Stitch.Repo.Migrations.UpdateSubscriptionEstimatedInvoiceAmount do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :estimated_invoice_amount, :integer, default: 0
    end
  end
end
