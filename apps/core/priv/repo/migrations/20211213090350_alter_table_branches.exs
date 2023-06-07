defmodule Core.Repo.Migrations.AlterTabelBranches do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:branches) do
      add :social_profile, :map
    end
  end
end
