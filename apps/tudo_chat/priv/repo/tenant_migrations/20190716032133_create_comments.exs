defmodule TudoChat.Repo.Migrations.CreateComments do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :title, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps()
    end

    create index(:comments, [:user_id])
    create index(:comments, [:post_id])
  end
end
