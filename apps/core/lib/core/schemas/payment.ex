defmodule Core.Schemas.Payment do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :transaction_id, :string
    field :from_bsp, :boolean
    field :from_cmr, :boolean
    field :payment_purpose, :map
    field :payment_method_token, :string
    field :invoice_amount, :float
    field :bsp_amount, :float
    field :tudo_booking_charges, :float
    field :tudo_booking_percentage, :float
    field :tudo_commission_charges, :float
    field :commission_percentage, :float
    field :insurance_amount, :float
    field :insurance_percentage, :float
    field :payment_gateway_fee_percentage, :float
    field :payment_gateway_fee, :float
    field :bsp_tip_amount, :float
    field :tudo_tip_amount, :float
    field :total_tip_amount, :float
    field :tudo_tip_percentage, :float
    field :tip_percentage, :float
    field :cancellation_fee, :float
    field :chargebacks, :float
    field :govt_fee, :float
    field :additional_fees, :map
    field :donation_amount, :float
    field :donations, :map
    field :tudo_reserve_amount, :float
    field :bsp_total_amount, :float
    field :tudo_total_amount, :float
    field :tudo_total_deducted_amount, :float
    field :total_transaction_amount, :float
    field :currency_symbol, :string
    field :paid_at, :utc_datetime
    belongs_to :payment_method, Core.Schemas.PaymentMethod, type: :string
    belongs_to :cmr_payment_status, Core.Schemas.PaymentStatus, type: :string
    belongs_to :bsp_payment_status, Core.Schemas.PaymentStatus, type: :string
    belongs_to :user, Core.Schemas.User
    belongs_to :branch, Core.Schemas.Branch
    belongs_to :business, Core.Schemas.Business
    #    field :merchant_id, :id

    timestamps()
  end

  @doc false
  def changeset(brain_tree_transaction, attrs) do
    brain_tree_transaction
    |> cast(attrs, [
      :user_id,
      :paid_at,
      :transaction_id,
      :bsp_amount,
      :tudo_booking_charges,
      :tudo_commission_charges,
      :insurance_amount,
      :payment_gateway_fee_percentage,
      :payment_gateway_fee,
      :bsp_tip_amount,
      :tudo_tip_amount,
      :tudo_reserve_amount,
      :bsp_total_amount,
      :tudo_total_amount,
      :tudo_total_deducted_amount,
      :total_tip_amount,
      :invoice_amount,
      :donation_amount,
      :total_transaction_amount,
      :from_bsp,
      :from_cmr,
      :payment_purpose,
      :cmr_payment_status_id,
      :bsp_payment_status_id,
      :payment_method_token,
      :branch_id,
      :business_id,
      :commission_percentage,
      :tudo_tip_percentage,
      :tip_percentage,
      :cancellation_fee,
      :chargebacks,
      :govt_fee,
      :additional_fees,
      :donations,
      :insurance_percentage,
      :tudo_booking_percentage,
      :currency_symbol,
      :payment_method_id
    ])
    |> validate_required([:user_id, :tudo_total_amount, :total_transaction_amount])
  end
end
