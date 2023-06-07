defmodule Core.Repo.Migrations.CreateTableServiceTypes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:service_types, primary_key: false) do
      add :id, :string, null: false, primary_key: true
      add :description, :string
    end
  end
end
