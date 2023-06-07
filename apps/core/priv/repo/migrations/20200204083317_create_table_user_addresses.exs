defmodule Core.Repo.Migrations.CreateTableUserAddresses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:user_addresses) do
      add :slug, :string
      add :primary, :boolean
      add :address, :string
      add :geo_location, :geometry
      add :zone_name, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_addresses, [:user_id])
  end
end
