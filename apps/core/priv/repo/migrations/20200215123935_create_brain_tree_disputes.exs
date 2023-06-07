defmodule Core.Repo.Migrations.CreateBrainTreeDisputes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:brain_tree_disputes) do
      add :title, :string
      add :description, :text
      add :attachments, {:array, :map}
      add :dispute_email, :string
      add :dispute_phone, :string
      add :transaction_id, :string
      add :dispute_status_id, references(:dispute_statuses, type: :varchar, on_delete: :nothing)

      add :dispute_category_id,
          references(:dispute_categories, type: :varchar, on_delete: :nothing)

      add :user_id, references(:users, on_delete: :nothing)
      add :branch_id, references(:branches, on_delete: :nothing)

      timestamps()
    end

    create index(:brain_tree_disputes, [:dispute_status_id])
    create index(:brain_tree_disputes, [:dispute_category_id])
    create index(:brain_tree_disputes, [:user_id])
    create index(:brain_tree_disputes, [:branch_id])
  end
end
