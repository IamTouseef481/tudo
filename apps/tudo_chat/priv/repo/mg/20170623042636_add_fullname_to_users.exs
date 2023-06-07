defmodule Stitch.Repo.Migrations.AddFullnameToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :fullname, :string
    end
  end
end
