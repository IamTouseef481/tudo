defmodule Core.Repo.Migrations.AddCashfreePayoutId do
  @moduledoc false
  use Ecto.Migration

  @table :bsp_transfers
  def change do
    alter table(@table) do
      add :payout_gateway, :string
    end
  end
end
