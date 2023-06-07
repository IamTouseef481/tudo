defmodule Core.Repo.Migrations.CreateTableMenuRoles do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:menu_roles) do
      add :doc_order, :integer
      add :menu_order, :integer
      add :menu_id, references(:menus, on_delete: :nothing)
      add :acl_role_id, references(:acl_roles, type: :varchar, on_delete: :nothing)

      timestamps()
    end

    create index(:menu_roles, [:menu_id])
    create index(:menu_roles, [:acl_role_id])
  end
end
