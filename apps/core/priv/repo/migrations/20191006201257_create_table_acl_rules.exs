defmodule Core.Repo.Migrations.CreateTableAclRules do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:acl_rules, primary_key: false) do
      add :role_id,
          references(:acl_roles, type: :varchar, on_delete: :delete_all, primary_key: true)

      add :res_id, references(:acl_res, on_delete: :delete_all, primary_key: true)
      add :action, :string, default: nil
      add :permission, :int, default: 1
      add :condition, :int, default: 1
      add :where_field, :string, default: nil
      add :where_value, :string, default: nil
      add :where_cond, :string, default: nil
      timestamps()
    end

    create index(:acl_rules, [:res_id])
    create index(:acl_rules, [:role_id])
    create index(:acl_rules, [:role_id, :res_id])
  end
end
