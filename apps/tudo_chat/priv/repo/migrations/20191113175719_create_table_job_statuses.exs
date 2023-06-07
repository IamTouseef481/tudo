defmodule Core.Repo.Migrations.CreateTableJobStatuses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:job_statuses, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
    end
  end
end
