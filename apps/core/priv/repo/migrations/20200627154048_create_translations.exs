defmodule Core.Repo.Migrations.CreateTranslations do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:translations) do
      add :slug, :string
      add :language, :string
      add :field_id, :integer
      add :translation, :string
      add :screen_id, references(:screens, type: :varchar, on_delete: :nothing)

      timestamps()
    end

    create index(:translations, [:screen_id])
  end
end
