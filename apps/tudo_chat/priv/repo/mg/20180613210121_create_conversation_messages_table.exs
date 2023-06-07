defmodule Stitch.Repo.Migrations.CreateConversationMessagesTable do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:conversation_messages) do
      # associations
      add(:conversation_id, references(:conversations, on_delete: :delete_all))
      add(:team_patient_id, references(:team_patients, on_delete: :delete_all))
      add(:provider_id, references(:users, on_delete: :delete_all))

      add(:text_content, :text)
      add(:fields, :map)
      add(:type, :string, default: false, null: false)
      add(:read_status, :map, default: "{}")
      add(:deleted, :boolean, default: false)
      add(:edited_at, :utc_datetime, null: true)

      # link info
      add(:has_links, :boolean, default: false, null: false)
      add(:link_previews_generated, :boolean, default: false, null: false)
      add(:link_previews, {:array, :map}, default: [], null: false)

      # client info
      add(:client_device_type, :string, default: "unknown", null: false)
      add(:client_os, :string, default: "unknown", null: false)
      add(:client_name, :string, default: "unknown", null: false)
      add(:request_id, :string)

      timestamps()
    end

    create(
      constraint(
        :conversation_messages,
        :conversation_messages_have_provider_or_patient,
        check: "(team_patient_id IS NOT NULL)::integer + (provider_id IS NOT NULL)::integer = 1"
      )
    )
  end
end
