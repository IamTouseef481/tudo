defmodule Core.Repo.Migrations.CreateHyperWalletTransferMethods do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:hyper_wallet_transfer_methods) do
      add :token, :text
      add :type, :string
      add :is_default, :boolean, default: false, null: false
      add :hw_user_id, references(:hyper_wallet_users, on_delete: :nothing)

      timestamps()
    end

    create index(:hyper_wallet_transfer_methods, [:hw_user_id])
  end
end
