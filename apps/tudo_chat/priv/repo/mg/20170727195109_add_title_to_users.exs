defmodule Stitch.Repo.Migrations.AddTitleToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :title, :string
    end
  end
end
