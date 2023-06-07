defmodule Stitch.Repo.Migrations.AddUniqueIndexToUserEmail do
  @moduledoc false
  use Ecto.Migration

  def change do
    create index(:users, [:email])
  end
end
