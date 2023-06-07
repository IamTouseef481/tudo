defmodule Core.Repo.Migrations.CreateTableJobCategories do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:job_categories, primary_key: false) do
      add :id, :string, null: false, primary_key: true
      add :description, :string
    end
  end
end
