defmodule Core.Repo.Migrations.AlterTableTudoCharges do
  use Ecto.Migration

  def change do
    alter table(:tudo_charges) do
      add :application_id, :string
      add :branch_id, references(:branches, on_delete: :nothing)
    end
  end
end
