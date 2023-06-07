defmodule Core.Repo.Migrations.CreateTableLanguages do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :code, :string
      add :name, :string
      add :language_text, :string
      add :is_active, :boolean, default: false, null: false

      timestamps()
    end
  end
end
