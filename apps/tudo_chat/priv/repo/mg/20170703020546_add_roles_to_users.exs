defmodule Stitch.Repo.Migrations.AddRolesToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :roles, {:array, :string}
    end
  end
end
