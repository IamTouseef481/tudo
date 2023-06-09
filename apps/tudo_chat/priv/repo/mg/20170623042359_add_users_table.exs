defmodule Stitch.Repo.Migrations.AddUsersTable do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :encrypted_password, :string

      timestamps()
    end
  end
end
