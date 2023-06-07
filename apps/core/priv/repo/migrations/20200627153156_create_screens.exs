defmodule Core.Repo.Migrations.CreateScreens do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:screens, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :text
    end
  end
end
