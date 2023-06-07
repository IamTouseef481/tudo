defmodule TudoChat.Repo.Migrations.CreateTableTenants do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:tenants) do
      add :name, :string
      add :status, :string

      timestamps()
    end

    create unique_index(:tenants, [:name])
  end
end
