defmodule Core.Repo.Migrations.CreateTableWarehouses do
  use Ecto.Migration

  def change do
    create table(:warehouses) do
      add :address, :string
      add :city, :string
      add :state, :string
      add :country, :string
      add :zip_code, :string
      add :phone, :string
      add :location, :geometry

      add :employee_id, references(:employees, on_delete: :nothing)

      timestamps()
    end
  end
end
