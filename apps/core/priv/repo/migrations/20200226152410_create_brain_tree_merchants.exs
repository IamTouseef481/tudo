defmodule Core.Repo.Migrations.CreateBrainTreeMerchants do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:brain_tree_merchants) do
      add :merchant_account_id, :string
      add :primary, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :branch_id, references(:branches, on_delete: :nothing)

      timestamps()
    end

    create index(:brain_tree_merchants, [:user_id])
    create index(:brain_tree_merchants, [:branch_id])
  end
end
