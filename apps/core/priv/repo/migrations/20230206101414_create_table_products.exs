defmodule Core.Repo.Migrations.CreateTableProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :description, :string
      add :purchase_uom, :string
      add :purchase_price, :float
      add :sale_uom, :string
      add :sale_price, :float
      add :currency, :string
      add :product_image, {:array, :string}
      add :thumb_nail, {:array, :string}
      add :attribute, {:array, :map}
      add :status, :string

      add :category_id, references(:product_categories, on_delete: :nothing, type: :string)
      add :primary_product_id, references(:products, on_delete: :nothing)
      add :branch_id, references(:branches, on_delete: :nothing)

      add :category_item_id,
          references(:product_category_items, on_delete: :nothing, type: :string)

      timestamps()
    end
  end
end
