defmodule Core.Repo.Migrations.AlterTableCreateBrainTreePaymentMethodsAddCardNumber do
  use Ecto.Migration

  def change do
    alter table(:brain_tree_payment_methods) do
      add :card_number, :string
    end

    create unique_index(:brain_tree_payment_methods, [:card_number])
  end
end
