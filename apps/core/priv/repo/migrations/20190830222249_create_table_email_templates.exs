defmodule Core.Repo.Migrations.CreateTableEmailTemplates do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:email_templates) do
      add :slug, :string
      add :cc, {:array, :string}
      add :subject, :string
      add :text_body, :text
      add :html_body, :text
      add :is_active, :boolean, default: true, null: false

      timestamps()
    end

    create index(:email_templates, [:slug])
  end
end
