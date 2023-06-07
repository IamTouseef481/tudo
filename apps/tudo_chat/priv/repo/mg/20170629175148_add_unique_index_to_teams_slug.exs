defmodule Stitch.Repo.Migrations.AddUniqueIndexToTeamsSlug do
  @moduledoc false
  use Ecto.Migration

  def change do
    create unique_index(:teams, [:slug])
  end
end
