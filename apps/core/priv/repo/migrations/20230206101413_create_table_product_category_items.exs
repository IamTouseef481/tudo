defmodule Core.Repo.Migrations.CreateTableProductCategoryItems do
  use Ecto.Migration

  def change do
    create table(:product_category_items, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
    end
  end
end
