defmodule Core.Repo.Migrations.CreateBrainTreePaymentMethods do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:brain_tree_payment_methods) do
      add :token, :text
      add :is_default, :boolean, default: false
      add :usage_purpose, {:array, :string}
      add :customer_id, references(:brain_tree_wallets, on_delete: :nothing)
      add :merchant_id, references(:brain_tree_merchants, on_delete: :nothing)
      add :type_id, references(:payment_methods, type: :varchar, on_delete: :nothing)

      timestamps()
    end

    create index(:brain_tree_payment_methods, [:type_id])
    create index(:brain_tree_payment_methods, [:merchant_id])
    create index(:brain_tree_payment_methods, [:customer_id])
  end
end
