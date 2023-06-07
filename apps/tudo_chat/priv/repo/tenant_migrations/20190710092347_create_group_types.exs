defmodule TudoChat.Repo.Migrations.CreateGroupTypes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:group_types) do
      add :name, :string
      add :desc, :string
      add :slug, :string

      timestamps()
    end

  end
end
