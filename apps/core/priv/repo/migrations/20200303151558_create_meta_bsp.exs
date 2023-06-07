defmodule Core.Repo.Migrations.CreateMetaBsp do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:meta_bsp) do
      add :type, :string
      add :terms_accepted, :boolean, default: true
      add :statistics, :map
      add :employee_id, references(:employees, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :branch_id, references(:branches, on_delete: :nothing)

      timestamps()
    end

    create index(:meta_bsp, [:employee_id])
    create index(:meta_bsp, [:user_id])
    create index(:meta_bsp, [:branch_id])
  end
end
