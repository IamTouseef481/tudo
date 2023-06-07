defmodule Core.Repo.Migrations.ProductManufacturers do
  use Ecto.Migration

  def change do
    create table(:product_manufacturers, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
    end
  end
end
