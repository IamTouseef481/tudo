defmodule Core.Repo.Migrations.CreateBrainTreeSubscriptions do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:brain_tree_subscriptions) do
      add :subscription_id, :string
      add :subscription_bsp_rule_id, references(:subscription_bsp_rules, on_delete: :nothing)
      add :subscription_cmr_rule_id, references(:subscription_cmr_rules, on_delete: :nothing)
      add :start_date, :date
      add :expiry_date, :date
      add :currency_symbol, :string
      add :user_id, references(:users, on_delete: :nothing)

      add :status_id,
          references(:brain_tree_subscription_statuses, type: :varchar, on_delete: :nothing)

      add :business_id, references(:businesses, on_delete: :nothing)

      timestamps()
    end

    create index(:brain_tree_subscriptions, [:user_id])
    create index(:brain_tree_subscriptions, [:status_id])
    create index(:brain_tree_subscriptions, [:subscription_bsp_rule_id])
    create index(:brain_tree_subscriptions, [:subscription_cmr_rule_id])
    create index(:brain_tree_subscriptions, [:business_id])
  end
end
