defmodule Core.Repo.Migrations.CreateLeads do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:leads) do
      add :arrive_at, :utc_datetime
      add :location, :geometry
      add :rating, :float
      add :is_flexible, :boolean, default: false, null: false
      add :country_service_id, references(:country_services, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:leads, [:country_service_id])
    create index(:leads, [:user_id])
  end
end
