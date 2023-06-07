defmodule TudoChat.Repo.Migrations.CreateFriendCircles do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:friend_circles) do
      add :request_message, :string
      add :user_from_id, :integer
      add :user_to_id, :integer
      add :status_id, references(:friends_circle_statuses, type: :varchar, on_delete: :nothing)
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps()
    end

    create index(:friend_circles, [:status_id, :group_id])
  end
end
