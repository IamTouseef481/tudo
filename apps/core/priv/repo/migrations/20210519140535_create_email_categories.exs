defmodule Core.Repo.Migrations.CreateEmailCategories do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:email_categories, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :text
    end
  end
end
