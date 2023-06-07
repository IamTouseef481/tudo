defmodule Core.Repo.Migrations.CreateDisputeStatuses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:dispute_statuses, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string

      #      timestamps()
    end
  end
end
