defmodule Core.Repo.Migrations.CreateTableBusinessTypes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:business_types) do
      add :name, :string

      timestamps()
    end
  end
end
