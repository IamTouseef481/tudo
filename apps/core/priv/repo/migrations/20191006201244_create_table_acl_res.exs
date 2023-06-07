defmodule Core.Repo.Migrations.CreateTableAclRes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:acl_res) do
      add :res, :string, null: true, unique: true
      add :parent, :string, default: nil

      timestamps()
    end
  end
end
