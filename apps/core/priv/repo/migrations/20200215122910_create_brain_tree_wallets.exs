defmodule Core.Repo.Migrations.CreateBrainTreeWallets do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:brain_tree_wallets) do
      add :customer_id, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:brain_tree_wallets, [:user_id])
  end
end
