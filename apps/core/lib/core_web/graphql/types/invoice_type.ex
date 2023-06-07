defmodule CoreWeb.GraphQL.Types.InvoiceType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :invoice_type do
    field :id, :integer
    field :job_id, :integer
    field :bid_proposal_id, :integer
    field :invoice_id, :string
    field :reference_no, :integer
    field :payment_type, :string
    field :discounts, list_of(:promotion_type)
    field :taxes, list_of(:tax_type)
    field :amounts, list_of(:amount_type)
    field :final_amount, :float
    field :total_charges, :float
    field :total_discount, :float
    field :total_tax, :float
    field :change, :boolean
    field :adjust, :boolean
    field :no_tax_concent, :boolean
    field :adjust_reason, :string
    field :adjust_count, :integer
    field :rep, :string
    field :bill_to, :string
    field :comment, list_of(:string)
    field :max_allowed_discount, :max_discount_type
    field :max_allowed_tax, :max_tax_type
    field :invoice_date, :string
    field :booking_percentage, :float
    field :insurance_percentage, :float
    field :business, :business_type, resolve: assoc(:business)
  end

  object :amount_type do
    field :service_id, list_of(:integer)
    field :service_title, :string
    field :description, :string
    field :unit_price, :float
    field :quantity, :integer
    field :discount_eligibility, :boolean
    field :tax_eligibility, :boolean
  end

  object :max_discount_type do
    field :allow, :boolean
    field :is_percentage, :boolean
    field :max_value, :float
    field :selected_value, :float
  end

  object :max_tax_type do
    field :allow, :boolean
    field :is_percentage, :boolean
    field :max_value, :float
    field :selected_value, :float
  end

  #  object :tax_type do
  #    field :id, :integer
  #    field :title, :string
  #    field :description, :string
  #    field :amount, :float
  #    field :tax_eligibility, :boolean
  #    field :business, :business_type, resolve: assoc(:business)
  #    field :tax_type_id, :string
  #  end

  #  input_object :invoice_input_type do
  #    field :job_id, non_null(:integer)
  #    field :comment, :string
  #    field :change, :boolean
  #    field :discount_ids, list_of(:integer)
  #    field :tax_ids, list_of(:integer)
  #  end

  #  input_object :invoice_update_type do
  #    field :invoice_id, non_null(:integer)
  #    field :job_id, :integer
  #    field :comment, :string
  #    field :amount, :amount
  ##    field :change, :boolean
  #    field :discount_ids, list_of(:integer)
  #    field :tax_ids, list_of(:integer)
  #  end

  input_object :amount do
    field :service_id, list_of(:integer)
    field :service_title, :string
    field :description, :string
    field :unit_price, :float
    field :quantity, :integer
    field :discount_eligibility, :boolean
    field :tax_eligibility, :boolean
  end

  input_object :invoice_get_type do
    field :job_id, non_null(:integer)
    field :payment_type, :string
  end

  input_object :invoice_adjust_type do
    field :id, non_null(:integer)
    field :adjust, non_null(:boolean)
    field :adjust_reason, :string
  end

  input_object :invoice_generate_type do
    field :id, :integer
    field :job_id, :integer
    field :invoice_id, :string
    field :reference_no, :integer
    field :payment_type, :string
    field :amounts, list_of(:amount)
    field :discounts, list_of(:add_discount_type)
    field :taxes, list_of(:add_tax_type)
    field :final_amount, non_null(:float)
    field :total_charges, non_null(:float)
    field :total_discount, non_null(:float)
    field :total_tax, non_null(:float)
    field :adjust, :boolean
    field :adjust_reason, :string
    field :change, :boolean
    field :rep, :string
    field :bill_to, :string
    field :comment, list_of(:string)
    field :business_id, :integer
  end

  input_object :invoice_update_type do
    field :job_id, non_null(:integer)
    field :amounts, list_of(non_null(:amount))
    field :discounts, list_of(:add_discount_type)
    field :taxes, list_of(:add_tax_type)
  end

  input_object :add_discount_type do
    field :id, :integer
    field :title, non_null(:string)
    field :description, :string
    field :value, non_null(:float)
    field :is_percentage, non_null(:boolean)
  end

  input_object :add_tax_type do
    field :id, :integer
    field :default, :boolean
    field :title, non_null(:string)
    field :description, :string
    field :value, non_null(:float)
    field :is_percentage, non_null(:boolean)
  end
end
