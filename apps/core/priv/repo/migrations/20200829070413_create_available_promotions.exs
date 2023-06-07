defmodule Core.Repo.Migrations.CreateAvailablePromotions do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:available_promotions) do
      add :title, :string
      add :additional, :boolean, default: false, null: false
      add :active, :boolean, default: true, null: false
      add :price, :float
      add :broadcast_range, :float, null: false
      add :begin_at, :utc_datetime, null: false
      add :expire_at, :utc_datetime, null: false
      add :used_at, :utc_datetime
      add :promotion_pricing_id, references(:promotion_purchase_price, on_delete: :nothing)
      add :branch_id, references(:branches, on_delete: :nothing)
      add :business_id, references(:businesses, on_delete: :nothing)

      timestamps()
    end

    create index(:available_promotions, [:branch_id])
    create index(:available_promotions, [:business_id])
    create index(:available_promotions, [:promotion_pricing_id])
  end
end
