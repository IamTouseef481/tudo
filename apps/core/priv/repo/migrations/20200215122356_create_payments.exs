defmodule Core.Repo.Migrations.CreatePayments do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :transaction_id, :string
      add :from_bsp, :boolean, default: false, null: false
      add :from_cmr, :boolean, default: false, null: false
      add :payment_purpose, :map
      add :payment_method_token, :string
      add :invoice_amount, :float, default: 0
      add :bsp_amount, :float, default: 0
      add :tudo_booking_charges, :float, default: 0
      add :tudo_booking_percentage, :float, default: 0
      add :tudo_commission_charges, :float, default: 0
      add :commission_percentage, :float, default: 0
      add :insurance_amount, :float, default: 0
      add :insurance_percentage, :float, default: 0
      add :payment_gateway_fee_percentage, :float, default: 0
      add :payment_gateway_fee, :float, default: 0
      add :bsp_tip_amount, :float, default: 0
      add :tudo_tip_amount, :float, default: 0
      add :total_tip_amount, :float, default: 0
      add :tudo_tip_percentage, :float, default: 0
      add :tip_percentage, :float, default: 0
      add :cancellation_fee, :float, default: 0
      add :chargebacks, :float, default: 0
      add :govt_fee, :float, default: 0
      add :additional_fees, :map
      add :donation_amount, :float, default: 0
      add :donations, :map
      add :tudo_reserve_amount, :float
      add :bsp_total_amount, :float
      add :tudo_total_amount, :float, default: 0
      add :tudo_total_deducted_amount, :float, default: 0
      add :total_transaction_amount, :float, default: 0
      add :currency_symbol, :string
      add :paid_at, :utc_datetime
      add :payment_method_id, references(:payment_methods, type: :varchar, on_delete: :nothing)

      add :cmr_payment_status_id,
          references(:payment_statuses, type: :varchar, on_delete: :nothing)

      add :bsp_payment_status_id,
          references(:payment_statuses, type: :varchar, on_delete: :nothing)

      add :user_id, references(:users, on_delete: :nothing)
      add :branch_id, references(:branches, on_delete: :nothing)
      add :business_id, references(:businesses, on_delete: :nothing)

      timestamps()
    end

    create index(
             :payments,
             [
               :user_id,
               :branch_id,
               :business_id,
               :payment_method_id,
               :cmr_payment_status_id,
               :bsp_payment_status_id
             ]
           )
  end
end
