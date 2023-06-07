defmodule Core.Repo.Migrations.BspEmailTemplates do
  use Ecto.Migration

  def change do
    create table(:bsp_email_templates) do
      add :send_in_blue_email_template_id, :integer
      add :send_in_blue_notification_template_id, :integer
      add :action, :string
      add :name, :string
      add :application_id, references(:applications, on_delete: :nothing, type: :string)
      add :branch_id, references(:branches, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:bsp_email_templates, [:branch_id, :action, :application_id])
  end
end
