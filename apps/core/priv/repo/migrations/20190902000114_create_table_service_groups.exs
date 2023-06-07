defmodule Core.Repo.Migrations.CreateSeedServiceGroups do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:service_groups) do
      add :name, :string
      add :is_active, :boolean, default: true

      timestamps()
    end
  end
end
