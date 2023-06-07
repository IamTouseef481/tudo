defmodule Core.Repo.Migrations.AlterTableEmailTemplatesAddFields do
  use Ecto.Migration

  def change do
    alter table(:email_templates) do
      add :send_in_blue_email_template_id, :integer
      add :send_in_blue_notification_template_id, :integer
      add :name, :string
    end

    drop index(:email_templates, [:slug])
    create unique_index(:email_templates, [:send_in_blue_email_template_id, :slug])
    create unique_index(:email_templates, [:send_in_blue_notification_template_id, :slug])
  end
end
