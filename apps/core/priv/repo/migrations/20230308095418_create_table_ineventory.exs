defmodule Core.Repo.Migrations.CreateTableIneventory do
  use Ecto.Migration

  def change do
    create table(:inventory) do
      add :bucket, :string
      add :quantity, :integer
      add :restoke_date, :utc_datetime

      add :product_id, references(:products, on_delete: :nothing)

      timestamps()
    end
  end
end
