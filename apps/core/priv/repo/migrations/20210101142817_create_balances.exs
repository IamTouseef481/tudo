defmodule Core.Repo.Migrations.CreateBalances do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:balances) do
      add :bsp_pending_balance, :float, default: 0
      add :bsp_available_balance, :float, default: 0
      add :bsp_cash_earning, :float, default: 0
      add :bsp_annual_earning, :float, default: 0
      add :bsp_total_earning, :float, default: 0
      add :bsp_annual_transfer, :float, default: 0
      add :bsp_total_transfer, :float, default: 0
      add :tudo_balance, :float, default: 0
      add :tudo_due_amount, :float, default: 0
      add :cmr_spent_amount, :float, default: 0
      add :bsp_spent_amount, :float, default: 0
      add :currency_symbol, :string
      add :branch_id, references(:branches, on_delete: :nothing)
      add :business_id, references(:businesses, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:balances, [:branch_id, :business_id, :user_id])
  end
end
