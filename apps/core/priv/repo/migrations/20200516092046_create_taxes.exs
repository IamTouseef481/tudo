defmodule Core.Repo.Migrations.CreateTaxes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:taxes) do
      add :title, :string
      add :description, :text
      add :value, :float
      add :is_percentage, :boolean
      add :business_id, references(:businesses, on_delete: :nothing)
      add :tax_type_id, references(:dropdowns, on_delete: :nothing)

      timestamps()
    end

    create index(:taxes, [:business_id])
  end
end
