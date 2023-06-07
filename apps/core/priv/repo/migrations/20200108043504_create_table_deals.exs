defmodule Core.Repo.Migrations.CreateTableDeals do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:deals) do
      add :user_id, references(:users, on_delete: :nothing)
      add :promotion_id, references(:promotions, on_delete: :nothing)
      add :service_id, references(:services, on_delete: :nothing)
      add :business_id, references(:businesses, on_delete: :nothing)

      timestamps()
    end

    create index(:deals, [:user_id])
    create index(:deals, [:promotion_id])
    create index(:deals, [:service_id])
    create index(:deals, [:business_id])
  end
end
