defmodule Stitch.Repo.Migrations.SplitFullnameToFirstNameAndLastName do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :fullname
      add :first_name, :string
      add :last_name, :string
    end
  end
end
