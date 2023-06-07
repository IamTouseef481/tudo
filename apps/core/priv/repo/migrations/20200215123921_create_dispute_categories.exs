defmodule Core.Repo.Migrations.CreateDisputeCategories do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:dispute_categories, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
      #      timestamps()
    end
  end
end
