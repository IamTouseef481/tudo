defmodule Stitch.Repo.Migrations.AddDefaultFavoriteGroupsToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :favorite_groups, {:array, :integer}, default: []
    end
  end
end
