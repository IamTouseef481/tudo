defmodule Core.Repo.Migrations.CreateMetaCmr do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:meta_cmr) do
      add :type, :string
      add :terms_accepted, :boolean, default: true
      add :statistics, :map
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:meta_cmr, [:user_id])
  end
end
