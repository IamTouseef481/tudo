defmodule Core.Repo.Migrations.CreateTableOrderHistory do
  use Ecto.Migration

  def change do
    create table(:order_history) do
      add :reason, :text
      add :inserted_by, :integer
      add :updated_by, :integer
      add :user_role, :string
      add :invoice_id, :integer
      add :payment_id, :integer
      add :created_at, :utc_datetime
      add :order_id, references(:orders, on_delete: :nothing)
      add :order_status_id, references(:job_statuses, type: :varchar, on_delete: :nothing)

      timestamps()
    end

    create index(:order_history, [:order_id])
  end
end
