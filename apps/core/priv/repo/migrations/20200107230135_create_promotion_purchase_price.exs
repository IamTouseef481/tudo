defmodule Core.Repo.Migrations.CreatePromotionPurchasePrice do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:promotion_purchase_price) do
      add :slug, :string
      add :base_price, :float
      add :broadcast_range, :integer
      add :promotion_cost, :float
      add :discounts, {:array, :map}
      add :discount_percentage, :float
      add :taxes, {:array, :map}
      add :tax_percentage, :float
      add :promotion_total_cost, :float
      add :currency_symbol, :string
      add :branch_id, references(:branches, on_delete: :nothing)

      timestamps()
    end

    create index(:promotion_purchase_price, [:branch_id])
  end
end
