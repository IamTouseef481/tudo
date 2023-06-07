defmodule Core.Repo.Migrations.CreateBrainTreeTokens do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:brain_tree_tokens) do
      add :token, :text
      add :user_id, references(:users, on_delete: :nothing)
      add :branch_id, references(:branches, on_delete: :nothing)

      timestamps()
    end

    create index(:brain_tree_tokens, [:user_id])
    create index(:brain_tree_tokens, [:branch_id])
  end
end
