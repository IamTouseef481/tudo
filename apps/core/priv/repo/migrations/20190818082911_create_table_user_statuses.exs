defmodule Core.Repo.Migrations.CreateTableUserStatuses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:user_statuses, primary_key: false) do
      add :id, :string, primary_key: true
      add :title, :string
      add :description, :string
    end
  end
end
