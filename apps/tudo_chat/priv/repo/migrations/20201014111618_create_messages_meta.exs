defmodule TudoChat.Repo.Migrations.CreateMessagesMeta do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:messages_meta) do
      add :liked, :boolean, default: false, null: false
      add :deleted, :boolean, default: false, null: false
      add :favourite, :boolean, default: false, null: false
      add :sent, :boolean, default: false, null: false
      add :read, :boolean, default: false, null: false
      add :user_id, :integer
      add :message_id, references(:com_group_messages, on_delete: :nothing)

      timestamps()
    end

    create index(:messages_meta, [:message_id])
  end
end
