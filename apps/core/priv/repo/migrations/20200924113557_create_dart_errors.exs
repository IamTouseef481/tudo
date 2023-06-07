defmodule Core.Repo.Migrations.CreateDartErrors do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:dart_errors) do
      add :tag, :string
      add :level, :string
      add :message, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:dart_errors, [:user_id])
  end
end
