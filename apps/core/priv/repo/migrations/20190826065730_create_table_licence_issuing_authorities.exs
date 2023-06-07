defmodule Core.Repo.Migrations.CreateTableLicenceIssuingAuthorities do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:licence_issuing_authorities) do
      add :name, :string
      add :is_active, :boolean, default: false, null: false
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create index(:licence_issuing_authorities, [:country_id])
  end
end
