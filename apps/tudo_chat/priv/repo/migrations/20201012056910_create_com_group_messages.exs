defmodule TudoChat.Repo.Migrations.CreateComGroupMessages do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:com_group_messages) do
      add :content_type, :string
      add :message, :text
      add :message_file, :map
      add :is_active, :boolean, default: false, null: false
      add :is_personal, :boolean, default: false, null: false
      add :forwarded, :boolean, default: false, null: false
      add :user_from_id, :integer
      add :user_to_id, :integer
      add :tagged_user_ids, {:array, :integer}
      add :job_status_id, references(:job_statuses, type: :varchar, on_delete: :nothing)
      add :parent_message_id, references(:com_group_messages, on_delete: :nothing)
      add :group_id, references(:groups, on_delete: :delete_all)
      add :created_at, :utc_datetime
      #      add :user_from_id, references(:users, on_delete: :nothing)
      #      add :user_to_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:com_group_messages, [:group_id, :parent_message_id, :job_status_id])
    #    create index(:com_group_messages, [:user_from_id])
    #    create index(:com_group_messages, [:user_to_id])
  end
end
