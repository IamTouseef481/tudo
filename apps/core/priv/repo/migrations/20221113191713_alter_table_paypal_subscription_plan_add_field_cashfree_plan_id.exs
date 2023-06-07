defmodule Core.Repo.Migrations.AlterTablePaypalSubscriptionPlansAddFieldCashfreePlanId do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:paypal_subscription_plans) do
      add :cashfree_plan_id, :string
    end
  end
end
