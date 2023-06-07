defmodule Core.Repo.Migrations.CreateTableServiceStatuses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:service_statuses, primary_key: false) do
      add :id, :string, null: false, primary_key: true
      add :description, :string
    end
  end
end
