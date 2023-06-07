defmodule Core.Repo.Migrations.UpdatePayoutgateway do
  @moduledoc false
  use Ecto.Migration

  @table :bsp_transfers
  def change do
    case Core.Payments.list_bsp_transfers() do
      transfers ->
        Enum.each(transfers, fn transfer ->
          Core.Payments.update_bsp_transfer(transfer, %{payout_gateway: "paypal"})
        end)
    end
  end
end
