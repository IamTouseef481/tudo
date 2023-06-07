defmodule CoreWeb.GraphQL.Types.CashPaymentType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :cash_payment_type do
    field :id, :integer
    field :pay_due_amount, :float
    field :paid_amount, :float
    field :returned_amount, :float
    field :tudo_due_amount, :float
    field :adjust, :boolean
    field :adjust_reason, :string
    field :cheque_amount, :float
    field :cheque_number, :integer
    field :cheque_image, list_of(:json)
    field :bank_name, :string
    field :signatory_name, :string
    field :in_favor_of_name, :string
    field :date, :date
    field :payment_details, :payment_type
    field :invoice, :invoice_type, resolve: assoc(:invoice)
  end

  input_object :cash_payment_input_type do
    field :payment_method_id, non_null(:string)
    field :amount, non_null(:float)
    field :payable_amount, :float
    field :password, :string
    field :get_insured, :boolean
    field :job_id, :integer
    field :invoice_id, :integer
    field :promotion_pricing_id, :integer
    field :paid_amount, :float
    #    cheque payment fields
    field :cheque_amount, :float
    field :cheque_number, :integer
    field :cheque_image, list_of(:file)
    field :bank_name, :string
    field :signatory_name, :string
    field :in_favor_of_name, :string
    field :date, :date
    #    cheque payment fields
    field :custom_fields, :custom_fields_type
  end

  input_object :cash_payment_generate_type do
    field :id, non_null(:integer)
    field :amount, non_null(:float)
    field :payment_method_id, non_null(:string)
    field :payable_amount, :float
    field :paid_amount, :float
    field :returned_amount, :float
    field :password, :string
    field :job_id, :integer
    field :invoice_id, :integer
    field :promotion_pricing_id, :integer
    field :cheque_amount, :float
    field :cheque_number, :integer
    field :cheque_image, list_of(:file)
    field :bank_name, :string
    field :signatory_name, :string
    field :in_favor_of_name, :string
    field :date, :date
    field :custom_fields, :custom_fields_type
  end

  input_object :cash_payment_adjust_type do
    field :id, non_null(:integer)
    field :adjust, non_null(:boolean)
    field :adjust_reason, :string
    field :payment_method_id, :string
  end

  input_object :cash_payment_update_type do
    field :id, non_null(:integer)
    field :paid_amount, :float
    field :cheque_amount, :float
    field :cheque_number, :integer
    field :cheque_image, list_of(:file)
    field :bank_name, :string
    field :signatory_name, :string
    field :in_favor_of_name, :string
    field :date, :date
  end

  input_object :cash_payment_get_type do
    field :invoice_id, non_null(:integer)
    field :payment_method_id, :string
  end
end
