defmodule TudoChat.Repo.Migrations.AlterGroups do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter(table(:groups)) do
      add :marketing_group, :boolean, default: false, null: false
    end
  end
end
