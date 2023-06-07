defmodule Core.Repo.Migrations.CreateDonations do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:donations) do
      add :title, :string
      add :slug, :string
      add :description, :text
      add :amount, :float
      add :status, :string
      add :valid_from, :utc_datetime
      add :valid_to, :utc_datetime
      add :country_id, references(:countries, on_delete: :nothing)
      add :charitable_organization_id, references(:charitable_organizations, on_delete: :nothing)

      timestamps()
    end

    create index(:donations, [:country_id])
    create index(:donations, [:charitable_organization_id])
  end
end
