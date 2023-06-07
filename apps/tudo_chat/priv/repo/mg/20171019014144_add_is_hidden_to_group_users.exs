defmodule Stitch.Repo.Migrations.AddIsHiddenToGroupUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:group_users) do
      add :is_hidden, :boolean, null: false, default: false
    end
  end
end
