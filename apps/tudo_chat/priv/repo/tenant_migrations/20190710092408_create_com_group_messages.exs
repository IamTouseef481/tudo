defmodule TudoChat.Repo.Migrations.CreateComGroupMessages do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:com_group_messages) do
      add :content_type, :string
      add :message, :text
      add :is_active, :boolean, default: false, null: false
      add :is_personal, :boolean, default: false, null: false
      add :group_id, references(:groups, on_delete: :nothing)
      add :user_from_id, references(:users, on_delete: :nothing)
      add :user_to_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:com_group_messages, [:group_id])
    create index(:com_group_messages, [:user_from_id])
    create index(:com_group_messages, [:user_to_id])
  end
end
