defmodule Core.Repo.Migrations.CreateTableMenus do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:menus) do
      add :slug, :string
      add :title, :string
      add :type, :string
      add :images, :map
      add :description, :text
      add :is_active, :boolean, default: true, null: false

      timestamps()
    end

    create index(:menus, [:slug, :type])
  end
end
