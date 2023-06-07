defmodule Core.Repo.Migrations.CreateEmailSettings do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:email_settings) do
      add :title, :string
      add :slug, :string
      add :is_active, :boolean, default: false, null: false
      add :category_id, references(:email_categories, on_delete: :nothing, type: :varchar)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:email_settings, [:category_id])
    create index(:email_settings, [:user_id])
  end
end
