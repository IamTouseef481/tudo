defmodule TudoChat.Repo.Migrations.CreateTableChannels do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :desc, :string
      add :status, :string

      timestamps()
    end

    create unique_index(:channels, [:name])
  end
end
