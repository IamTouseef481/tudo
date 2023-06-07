defmodule Core.Repo.Migrations.CreateTableOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :quantity, :integer

      add :order_id, references(:orders, on_delete: :nothing)
      add :product_id, references(:products, on_delete: :nothing)

      timestamps()
    end
  end
end
