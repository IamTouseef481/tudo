defmodule Core.Repo.Migrations.CreateTablePromotions do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:promotions) do
      add :title, :string
      add :description, :text
      add :photos, {:array, :map}
      add :begin_date, :utc_datetime
      add :end_date, :utc_datetime
      add :expiry_count, :integer
      add :max_user_count, :integer
      add :expire_after_amount, :float
      add :valid_after_amount, :float
      add :value, :float
      add :is_combined, :boolean, default: true
      add :favourite, :boolean, default: false
      add :is_percentage, :boolean
      add :service_ids, {:array, :integer}
      add :radius, :float
      add :shareable_link, :string
      add :zone_ids, {:array, :integer}
      add :term_and_condition_ids, {:array, :integer}
      add :branch_id, references(:branches, on_delete: :nothing)
      add :discount_type_id, references(:dropdowns, on_delete: :nothing)

      add :promotion_status_id,
          references(:promotion_statuses, type: :varchar, on_delete: :nothing)

      add :promotion_pricing_id, references(:promotion_purchase_price, on_delete: :nothing)

      timestamps()
    end

    create index(:promotions, [
             :branch_id,
             :discount_type_id,
             :promotion_status_id,
             :promotion_pricing_id
           ])
  end
end
