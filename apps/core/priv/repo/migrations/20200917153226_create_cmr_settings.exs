defmodule Core.Repo.Migrations.CreateCMRSettings do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:cmr_settings) do
      add :title, :string
      add :slug, :string
      add :type, :string
      add :fields, {:array, :map}
      add :user_id, references(:users, on_delete: :nothing)
      add :employee_id, references(:employees, on_delete: :nothing)
      #      add :branch_id, references(:branches, on_delete: :nothing)

      timestamps()
    end

    create index(:cmr_settings, [:user_id])
    create index(:cmr_settings, [:employee_id])
    #    create index(:cmr_settings, [:branch_id])
  end
end
