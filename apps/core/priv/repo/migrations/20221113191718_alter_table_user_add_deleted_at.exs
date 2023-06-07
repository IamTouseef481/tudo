defmodule Core.Repo.Migrations.AlterTableUsersAddDeletedAt do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :deleted_at, :utc_datetime
    end
  end
end
