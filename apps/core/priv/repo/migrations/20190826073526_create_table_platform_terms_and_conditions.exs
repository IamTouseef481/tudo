defmodule Core.Repo.Migrations.CreateTablePlatformTermsAndConditions do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:platform_terms_and_conditions) do
      add :slug, :string
      add :type, :string
      add :text, :text
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :url, :string
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create index(:platform_terms_and_conditions, [:country_id, :slug])
    #    create unique_index(:platform_terms_and_conditions, [:url, :slug])
  end
end
