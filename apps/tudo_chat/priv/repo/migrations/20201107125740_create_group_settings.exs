defmodule TudoChat.Repo.Migrations.CreateGroupSettings do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:group_settings) do
      add :title, :string
      add :slug, :string
      add :fields, :map
      add :user_id, :integer
      add :group_id, references(:groups, on_delete: :delete_all)

      timestamps()
    end

    create index(:group_settings, [:group_id])
  end
end
