defmodule Core.Repo.Migrations.CreateTableHolidays do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:holidays) do
      add :title, :string
      add :type, :string
      add :description, :text
      add :from, :utc_datetime
      add :to, :utc_datetime
      add :purpose, :string
      add :branch_id, references(:branches, on_delete: :nothing)
      #      add :business_id, references(:businesses, on_delete: :nothing)

      timestamps()
    end

    create index(:holidays, [:branch_id])
    #    create index(:holidays, [:business_id])
  end
end
