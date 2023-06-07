defmodule TudoChat.Repo.Migrations.CreateGroupStatuses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:group_statuses, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
    end
  end
end
