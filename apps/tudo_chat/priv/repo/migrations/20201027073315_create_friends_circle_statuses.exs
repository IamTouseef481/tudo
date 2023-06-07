defmodule TudoChat.Repo.Migrations.CreateFriendsCircleStatuses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:friends_circle_statuses, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
    end
  end
end
