defmodule Core.Repo.Migrations.CreateAvailableSubscriptionFeatures do
  use Ecto.Migration

  def change do
    create table(:available_subscription_features) do
      add :title, :string
      add :subscription_feature_slug, :string
      add :price, :float
      add :begin_at, :utc_datetime
      add :expire_at, :utc_datetime
      add :used_at, :utc_datetime
      add :active, :boolean, null: false, default: false
      add :branch_id, references(:branches, on_delete: :nothing)

      timestamps()
    end

    create index(:available_subscription_features, [:branch_id])
  end
end
