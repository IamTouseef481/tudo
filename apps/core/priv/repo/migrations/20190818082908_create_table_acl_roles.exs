defmodule Core.Repo.Migrations.CreateTableAclRoles do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:acl_roles, primary_key: false) do
      add :id, :string, null: false, primary_key: true
      add :parent, :string, default: nil

      timestamps()
    end
  end
end
