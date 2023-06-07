defmodule CoreWeb.GraphQL.Types.CashfreePaymentType do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Core.Repo

  # Response Data Objects...

  object :cashfree_order_type do
    field :cf_order_id, :string
    field :order_id, :string
    field :entity, :string
    field :order_currency, :string
    field :order_amount, :float
    field :order_expiry_time, :string
    field :customer_details, :cashfree_customer_type
    field :order_meta, :cashfree_order_meta_type
    field :payments, :json
    field :order_status, :string
    field :order_token, :string
    field :order_note, :string
    # field :payment_method, :string
    field :channel, :string
    field :action, :string
    field :data, :json
    field :cf_payment_id, :integer
    field :payment_session_id, :string
    # field :payment_link, :string
    field :settlements, :json
    field :refunds, :json
  end

  object :cf_payment_method_type do
    field :card, :card_type
  end

  object :card_type do
    field :channel, :string
    field :card_number, :string
    field :card_holder_name, :string
    field :card_expiry_mm, :string
    field :card_expiry_yy, :string
    field :card_cvv, :string
  end

  object :cashfree_order_meta_type do
    field :return_url, :string
    field :notify_url, :string
    field :payment_methods, :string
  end

  object :cashfree_customer_type do
    field :customer_id, :string
    field :customer_email, :string
    field :customer_phone, :string
    field :customer_name, :string
  end

  object :cashfree_subscription_type do
    field :message, :string
  end

  object :beneficiary_type do
    field :beneficiary_id, :string
    field :message, :string
    field :transfer_mode, list_of(:string)
  end

  object :list_beneficiary_type do
    field :beneficiary_id, :string
    field :bank_account, :string
    field :ifsc, :string
    field :vpa, :string
    field :phone, :string
    field :email, :string
    field :transfer_mode, list_of(:string)
  end

  # Input Objects

  input_object :create_cashfree_order_and_pay_input_type do
    field :access_token, :string
    #    field :intent, :string
    #    field :customer_detail, :customer_detail_input_type
    field :description, :string
    field :soft_descriptor, :string
    field :items, :string
    field :shipping, :string
    field :amount, non_null(:float)
    #    local
    #    field :payment_method_id, non_null(:string)
    field :payable_amount, :float
    field :password, :string
    field :get_insured, :boolean
    # job payments
    field :job_id, :integer
    # job payments
    field :invoice_id, :integer
    # for promotion purchase payment
    field :promotion_pricing_id, :integer
    # for any subscription feature purchase payment
    field :subscription_feature_slug, :string
    # for any subscription feature purchase payment
    field :quantity, :integer
    field :branch_id, :integer
    # for tudo dues payment to tudo from cash payments
    field :cash_payment_id, :integer
    field :custom_fields, :custom_fields_type
    # payment_methods
    field :payment_method, :cf_payment_method_input_type
  end

  input_object :cashfree_order_input_type do
    field :access_token, :string
    field :description, :string
    field :soft_descriptor, :string
    field :items, :string
    field :shipping, :string
    field :amount, non_null(:float)
    field :payable_amount, :float
    field :password, :string
    field :get_insured, :boolean
    # job payments
    field :job_id, :integer
    field :order_id, :integer
    field :product_order_id, :integer
    # job payments
    field :invoice_id, :integer
    # for promotion purchase payment
    field :promotion_pricing_id, :integer
    # for any subscription feature purchase payment
    field :subscription_feature_slug, :string
    # for any subscription feature purchase payment
    field :quantity, :integer
    field :branch_id, :integer
    # for tudo dues payment to tudo from cash payments
    field :cash_payment_id, :integer
    field :custom_fields, :custom_fields_type
  end

  input_object :cf_payment_method_input_type do
    field :card, :card_input_type
    field :upi, :upi_input_type
    field :netbanking, :netbanking_input_type
    field :app, :app_input_type
    field :emi, :emi_input_type
    field :cardless_emi, :cardlessemi_input_type
    field :paylater, :paylater_input_type
  end

  input_object :card_input_type do
    field :channel, :card_channel_type
    field :card_number, :string
    field :card_holder_name, :string
    field :card_expiry_mm, :string
    field :card_expiry_yy, :string
    field :card_cvv, :string
    field :instrument_id, :string
    field :cryptogram, :string
    field :token_requestor_id, :string
    field :card_display, :string
    field :card_alias, :string
    field :card_bank_name, :string
    field :emi_tenure, :integer
  end

  input_object :upi_input_type do
    field :channel, :upi_channel_type
    field :upi_id, :string
    field :upi_expiry_minutes, :integer
    field :authorize_only, :boolean
    field :authorization, :authorization_input_type
  end

  input_object :netbanking_input_type do
    field :channel, :channel_type
    field :netbanking_bank_code, non_null(:integer)
  end

  input_object :app_input_type do
    field :channel, :channel_type
    field :phone, :string
    field :provider, :provider_type
  end

  input_object :emi_input_type do
    field :channel, :channel_type
    field :card_number, :string
    field :card_holder_name, :string
    field :card_expiry_mm, :string
    field :card_expiry_yy, :string
    field :card_cvv, :string
    field :card_alias, :string
    field :card_bank_name, :card_bank_name_type
    field :emi_tenure, :integer
  end

  input_object :cardlessemi_input_type do
    field :channel, :channel_type
    field :phone, :string
    field :provider, :cardless_emi_provider_type
  end

  input_object :paylater_input_type do
    field :channel, :channel_type
    field :phone, :string
    field :provider, :pay_later_provider_type
  end

  enum :provider_type do
    value(:gpay)
    value(:phonepe)
    value(:ola)
    value(:paytm)
    value(:amazon)
    value(:airtel)
    value(:freecharge)
    value(:mobikwik)
    value(:jio)
  end

  enum :card_bank_name_type do
    value(:Kotak)
    value(:ICICI)
    value(:RBL)
    value(:BOB)
    value(:Standard_Chartered)
    value(:HDFC)
  end

  enum :cardless_emi_provider_type do
    value(:flexmoney)
    value(:zestmoney)
  end

  enum :pay_later_provider_type do
    value(:kotak)
    value(:flexipay)
    value(:zestmoney)
    value(:lazypay)
    value(:simpl)
    value(:olapostpaid)
  end

  enum :card_channel_type do
    value(:link)
    value(:post)
  end

  enum :upi_channel_type do
    value(:collect)
    value(:post)
    value(:qrcode)
  end

  enum :channel_type do
    value(:link)
  end

  input_object :authorization_input_type do
    #    field :channel, :string
    field :approve_by, :string
    field :start_time, :string
    field :end_time, :string
  end

  input_object :customer_detail_input_type do
    field :customer_id, non_null(:string)
    field :customer_email, non_null(:string)
    field :customer_phone, non_null(:string)

    field :customer_bank_account_number, :string
    field :customer_bank_ifsc, :string
    field :customer_bank_code, :string
  end

  input_object :cashfree_order_meta_input_type do
    field :return_url, :string
    field :notify_url, :string
    field :payment_methods, :string
  end

  input_object :cashfree_subscription_input_type do
    field :business_id, non_null(:integer)

    field :subscription_id, non_null(:string)
    #    field :plan_id, non_null :string
    field :customer_detail, non_null(:customer_detail_input_type)

    field :first_charge_date, :date
    field :expires_on, :datetime
    field :subscription_note, :string
    field :auth_amount, :float
    field :notification_channel, :string
  end

  input_object :beneficiary_input_type do
    field :bank_account, :string
    field :password, :string
    field :default, :boolean
    field :ifsc, :string
    field :field, :string
    field :state, :string
    field :vpa, :string
    field :pincode, :string
    field :phone, non_null(:string)
  end

  input_object :cashfree_payout_input_type do
    field :amount, non_null(:float)
    field :branch_id, non_null(:integer)
    field :bene_id, non_null(:string)
    field :transfer_mode, :transfer_mode_type
    field :payment_instrument_id, :string
    field :remarks, :string
  end

  enum :transfer_mode_type do
    value(:banktransfer)
    value(:paytm)
    value(:amazonPay)
    value(:upi)
  end

  input_object :delete_beneficiary_input_type do
    field :password, :string
    field :bene_id, non_null(:string)
  end

  input_object :get_cashfree_order_input_type do
    field :order_id, non_null(:string)
    field :job_id, :integer
    field :product_order_id, :integer
    field :data, :json
    field :cf_payment_id, :integer
    # for promotion purchase payment
    field :promotion_pricing_id, :integer
    field :branch_id, :integer
    # for any subscription feature purchase payment
    field :subscription_feature_slug, :string
  end
end
