defmodule TudoChat.Repo.Migrations.CreateGroupTypes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:group_types, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
    end
  end
end
