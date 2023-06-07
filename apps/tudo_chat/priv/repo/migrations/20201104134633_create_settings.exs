defmodule TudoChat.Repo.Migrations.CreateSettings do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :title, :string
      add :slug, :string
      add :type, :string
      add :user_id, :integer
      add :fields, :map

      timestamps()
    end
  end
end
