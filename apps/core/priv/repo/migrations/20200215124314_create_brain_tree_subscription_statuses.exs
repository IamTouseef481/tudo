defmodule Core.Repo.Migrations.CreateBrainTreeSubscriptionStatuses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:brain_tree_subscription_statuses, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
    end
  end
end
