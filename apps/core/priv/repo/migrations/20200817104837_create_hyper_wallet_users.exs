defmodule Core.Repo.Migrations.CreateHyperWalletUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:hyper_wallet_users) do
      add :user_token, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:hyper_wallet_users, [:user_id])
  end
end
