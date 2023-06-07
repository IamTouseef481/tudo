defmodule Core.Repo.Migrations.CreateBspTransfers do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:bsp_transfers) do
      add :payout_id, :text
      add :amount, :float
      add :payout_fee, :float
      add :currency, :string
      add :currency_symbol, :string
      add :transfer_at, :utc_datetime
      add :branch_id, references(:branches, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:bsp_transfers, [:branch_id, :user_id])
  end
end
