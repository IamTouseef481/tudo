defmodule Core.Repo.Migrations.CreateTableProductCategories do
  use Ecto.Migration

  def change do
    create table(:product_categories, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
    end
  end
end
