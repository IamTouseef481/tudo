defmodule CoreWeb.GraphQL.Types.PaymentType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :token_type do
    field :id, :integer
    field :token, :string
    field :user, :user_type, resolve: assoc(:user)
  end

  object :brain_tree_customer_type do
    field :id, :integer
    field :company, :string
    field :customer_id, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :phone, :string
    field :website, :string
    field :payment_methods, list_of(:json)
    field :credit_cards, list_of(:json)
    #    field :paypal_accounts, list_of :json
    field :user, :user_type, resolve: assoc(:user)
  end

  object :bt_payment_method_type do
    field :token, :string
    field :usage_purpose, list_of(:string)
    field :customer_id, :string
    field :card_type, :string
    field :device_data, :string
    #    field :cvv, :string
    field :last_4, :string
    field :cardholder_name, :string
    field :expiration_date, :string
    field :expiration_month, :string
    field :expiration_year, :string
    field :expired, :boolean
    field :prepaid, :string
    field :payroll, :string
    field :venmo_sdk, :boolean
    field :subscriptions, list_of(:json)
    field :verifications, list_of(:json)
    field :unique_number_identifier, :string
    field :user, :user_type, resolve: assoc(:user)
    field :branch, :branch_type, resolve: assoc(:branch)
  end

  object :transaction_type do
    field :id, :string
    field :user_name, :string
    field :credit_card, :json
    field :merchant_account_id, :string
    field :amount, :float
    field :tax_amount, :float
    field :order_id, :string
    field :type, :string
    field :currency_iso_code, :string
    field :add_ons, list_of(:json)
    field :escrow_status, :string
    field :disputes, list_of(:json)
    field :subscription_id, :string
    field :subscription_details, :json
    field :payment_instrument_type, :string
    field :disbursement_details, :json
    field :processor_authorization_code, :string
    field :status_history, list_of(:json)
    field :custom_fields, :json
    field :verify_item_amount, :boolean
    field :item_slug, :string
    field :user, :user_type, resolve: assoc(:user)
    field :branch, :branch_type, resolve: assoc(:branch)
  end

  object :donation_type do
    field :id, :integer
    field :title, :string
    field :slug, :string
    field :description, :string
    field :amount, :float
    field :status, :string
    field :valid_from, :datetime
    field :valid_to, :datetime
    field :country, :country_type, resolve: assoc(:country)

    field :charitable_organization, :charitable_organization_type,
      resolve: assoc(:charitable_organization)
  end

  object :charitable_organization_type do
    field :id, :id
    field :name, :string
    field :phone, :string
    field :licence_no, :string
    field :licence_photos, list_of(:json)
    field :licence_expiry_date, :datetime
    #    field :personal_identification, :json
    field :profile_pictures, list_of(:json)
    field :employees_count, :integer
    field :settings, :json
    field :est_year, :datetime
    field :address, :json
    field :zone_ids, list_of(:integer)
    field :is_active, :boolean
    field :rating, :float
    field :geo, :json

    field :licence_issuing_authority, :licence_issuing_authorities_type,
      resolve: assoc(:licence_issuing_authority)

    field :city, :city_type, resolve: assoc(:city)
  end

  object :merchant_account_type do
    field :id, :string
    field :business, :json
    field :currency_iso_code, :string
    field :default, :boolean
    field :funding, :json
    field :individual, :json
    field :status, :string
    field :master_merchant_account, :json
  end

  object :credit_card_verification_type do
    field :id, :string
    field :billing_address_details_postal_code, :string
    field :created_at, :string
    field :credit_card_card_type, list_of(:string)
    field :credit_card_cardholder_name, :string
    field :credit_card_expiration_date, :string
    field :credit_card_number, :string
    field :customer_email, :string
    field :customer_id, :string
    field :payment_method_token, :string
  end

  object :subscription_type do
    field :subscription_id, :string
    field :add_ons, list_of(:json)
    field :balance, :string
    field :start_date, :date
    field :expiry_date, :date
    field :billing_day_of_month, :string
    field :billing_period_end_date, :string
    field :billing_period_start_date, :string
    field :created_at, :string
    field :current_billing_cycle, :string
    field :days_past_due, :string
    field :description, :string
    field :descriptor, :json
    field :discounts, list_of(:json)
    field :failure_count, :string
    field :first_billing_date, :string
    field :id, :string
    field :merchant_account_id, :string
    field :never_expires, :boolean
    field :next_bill_amount, :string
    field :next_billing_date, :string
    field :next_billing_period_amount, :string
    field :number_of_billing_cycles, :integer
    field :paid_through_date, :string
    field :payment_method_token, :string
    field :plan_id, :string
    field :price, :string
    field :status, :string
    field :status_history, list_of(:json)
    field :transactions, list_of(:json)
    field :trial_duration, :string
    field :trial_duration_unit, :string
    field :trial_period, :string
    field :updated_at, :string
    field :currency_symbol, :string

    field :subscription_bsp_rule, :subscription_bsp_rule_type,
      resolve: assoc(:subscription_bsp_rule)

    field :business, :business_type, resolve: assoc(:business)
    field :user, :user_type, resolve: assoc(:user)
  end

  object :paypal_account_type do
    field :id, :integer
    field :customer_id, :string
    field :email, :string
    field :image_url, :string
    field :payer_info, :string
    field :default, :boolean
    field :is_channel_initated, :boolean
    field :subscriptions, list_of(:subscription_type)
    field :user, :user_type, resolve: assoc(:user)
    field :branch, :branch_type, resolve: assoc(:branch)
  end

  object :dispute_category_type do
    field :id, :id
    field :description, :string
  end

  object :dispute_status_type do
    field :id, :id
    field :description, :string
  end

  object :subscription_bsp_rule_type do
    field :slug, :string
    field :consumer_family_member, :boolean
    field :data_privacy, :boolean
    field :n_ter, :boolean
    field :tenant_business_providers, :integer
    field :data_retention, :integer
    field :data_unit, :string
    field :package_validity, :string
    field :time_unit, :string
    field :package_monthly_price, :float
    field :package_annual_price, :float
    field :payment_with_applied_fee, :boolean
    field :allow_additional_employee, :boolean
    field :allow_additional_branch_office, :boolean
    field :allow_additional_tenant_business, :boolean
    field :allow_additional_promotion, :boolean
    field :allow_additional_job_posting, :boolean
    field :promotion_validity, :integer
    field :additional_employee_charges, :float
    field :reports_period, :integer
    field :additional_promotion_charges, :float
    field :additional_job_posting_charges, :float
    field :bus_net, :boolean
    field :deals, :boolean
    field :employees_count, :integer
    field :business_private_messaging, :boolean
    field :branch_offices, :integer
    field :consumer_private_messaging, :boolean
    field :consolidated_calendar, :boolean
    field :data_limit, :integer
    field :business_verification, :boolean
    field :promotions, :integer
    field :package_id, :string
    field :job_search_apply, :boolean
    field :job_posting_validity, :integer
    field :additional_tenant_business_charges, :float
    field :tudo_portion_of_consumer_tip, :integer
    field :package_name, :string
    field :additional_branch_office_charges, :float
    field :job_postings, :integer
    field :tasks_events, :boolean
    field :show_adds, :boolean
    field :service_appointments, :string
    field :my_net, :boolean
    field :country, :country_type, resolve: assoc(:country)
  end

  object :payment_type do
    field :id, :integer
    field :transaction_id, :string
    field :from_cmr, :boolean
    field :from_bsp, :boolean
    field :payment_purpose, :json
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
    field :additional_fees, :json
    field :donation_amount, :float
    field :donations, :json
    field :bsp_total_amount, :float
    field :tudo_total_amount, :float
    field :tudo_total_deducted_amount, :float
    field :total_transaction_amount, :float
    field :paid_at, :datetime
    field :currency_symbol, :string
    field :invoice, :invoice_type
    field :job, :job_type
    field :subscription, :subscription_type
    field :paypal_subscription, :paypal_subscription_type
    field :promotion_pricing, :promotion_price_type
    field :cash_payment, :cash_payment_type
    field :subscription_features, list_of(:subscription_features_type)
    field :payment_method, :payment_method_type, resolve: assoc(:payment_method)
    field :cmr_payment_status, :payment_status_type, resolve: assoc(:cmr_payment_status)
    field :bsp_payment_status, :payment_status_type, resolve: assoc(:bsp_payment_status)
    field :user, :user_type, resolve: assoc(:user)
    field :branch, :branch_type, resolve: assoc(:branch)
    field :business, :business_type, resolve: assoc(:business)
  end

  object :subscription_features_type do
    field :id, :string
    field :subscription_feature_slug, :string
    field :title, :string
    field :price, :string
    field :begin_at, :datetime
    field :expire_at, :datetime
    field :used_at, :datetime
    field :branch, :branch_type
  end

  object :payment_method_type do
    field :id, :string
    field :description, :string
  end

  object :payment_status_type do
    field :id, :string
    field :description, :string
  end

  object :bsp_earning_type do
    field :bsp_earnings, list_of(:payment_type)
    field :bsp_tranfers, list_of(:bsp_tranfer_type)
    field :annual_earning, :float
    field :available_funds, :float
    field :tudo_reserve, :float
    field :annual_transfers, :float
    field :tudo_due_amount, :float
    field :bsp_cash_earning, :float
  end

  object :cmr_paid_payment_type do
    field :total_paid_amount, :float
    field :payments, list_of(:payment_type)
  end

  object :bsp_tranfer_type do
    field :id, :integer
    field :payout_fee, :float
    field :payout_id, :string
    field :amount, :float
    field :transfer_at, :datetime
    field :currency, :string
    field :payout_gateway, :string
    field :currency_symbol, :string
    field :user, :user_type, resolve: assoc(:user)
    field :branch, :branch_type, resolve: assoc(:branch)
  end

  input_object :token_input_type do
    field :branch_id, non_null(:integer)
  end

  input_object :brain_tree_customer_get_type do
    #    field :branch_id, non_null :integer
  end

  input_object :brain_tree_customer_input_type do
    field :first_name, :string
    field :last_name, :string
    field :company, :string
    field :phone, :string
    field :email, :string
    field :website, :string
    field :fax, :string
    field :device_data, :string
    field :custom_fields, :string
    field :risk_data, :risk_data_type
  end

  input_object :risk_data_type do
    field :customer_browser, :string
    field :customer_ip, :string
  end

  input_object :credit_card_type do
    field :usage_purpose, list_of(:string)
    field :billing_address, :billing_address_type
    field :billing_address_id, :string
    field :cardholder_name, :string
    field :customer_id, :string
    field :cvv, :string
    field :expiration_date, :string
    field :expiration_month, :string
    field :expiration_year, :string
    field :number, :string
    field :payment_method_nonce, :string
    field :token, :string
    field :options, :credit_card_options_type
  end

  input_object :billing_address_type do
    field :company, :string
    field :country_code_alpha2, :string
    field :country_code_alpha3, :string
    field :country_code_numeric, :string
    field :country_name, :string
    field :extended_address, :string
    field :first_name, :string
    field :last_name, :string
    field :locality, :string
    field :postal_code, :string
    field :region, :string
    field :street_address, :string
  end

  input_object :credit_card_options_type do
    field :fail_on_duplicate_payment_method, :boolean
    field :make_default, :boolean
    field :verification_amount, :string
    field :verify_card, :boolean
    field :verification_merchant_account_id, :string
  end

  input_object :payment_method_get_type do
    field :token, non_null(:string)
  end

  input_object :payment_method_input_type do
    field :type_id, :string
    field :usage_purpose, list_of(:string)
    field :customer_id, :string
    field :device_data, :string
    field :number, :string
    field :cvv, :string
    field :cardholder_name, :string
    #    field :expiration_date, :string
    field :expiration_month, :string
    field :expiration_year, :string
    field :payment_method_nonce, :string
    field :billing_address_id, :string
    field :billing_address, :billing_address_type
    field :options, :credit_card_options_type
  end

  input_object :payment_method_update_type do
    field :token, non_null(:string)
    field :type_id, :string
    field :usage_purpose, list_of(:string)
    field :number, :string
    field :device_data, :string
    field :cvv, :string
    field :cardholder_name, :string
    #    field :expiration_date, :string
    field :expiration_month, :string
    field :expiration_year, :string
    field :payment_method_nonce, :string
    field :options, :credit_card_options_type
  end

  input_object :transaction_get_type do
    field :transaction_id, non_null(:string)
  end

  input_object :transaction_get_by_type do
    field :from, :datetime
    field :to, :datetime
    field :operator, :string
  end

  input_object :transaction_input_type do
    field :job_id, :integer
    field :invoice_id, :integer
    field :payment_method_id, non_null(:string)
    field :promotion_pricing_id, :integer
    field :get_insured, :boolean
    field :password, :string
    field :merchant_id, :integer
    field :merchant_account_id, :string
    field :customer_id, :string
    field :amount, non_null(:float)
    field :payable_amount, :float
    field :token, :string
    field :channel, :string
    field :customer, :transaction_customer_type
    field :discount_amount, :string
    field :order_id, :string
    field :payment_method_nonce, :string
    field :payment_method_token, :string
    field :purchase_order_number, :string
    field :recurring, :boolean
    field :risk_data, :risk_data_type
    field :service_fee_amount, :string
    field :shipping_amount, :string
    field :ships_from_postal_code, :string
    field :shipping, :shipping_type
    field :tax_amount, :string
    field :tax_exempt, :boolean
    field :transaction_source, :string
    field :custom_fields, :custom_fields_type
    field :options, :transaction_options_type
    field :credit_card, :payment_method_input_type
  end

  input_object :transaction_refund_type do
    field :amount, non_null(:string)
    field :transaction_id, non_null(:string)
    field :order_id, :string
  end

  input_object :transaction_customer_type do
    field :first_name, :string
    field :last_name, :string
    field :company, :string
    field :phone, :string
    field :email, :string
    field :website, :string
  end

  input_object :shipping_type do
    field :amount, :string
    #    field :first_name, :string
    #    field :last_name, :string
    #    field :company, :string
    #    field :phone, :string
    #    field :email, :string
    #    field :website, :string
  end

  input_object :transaction_options_type do
    field :add_billing_address_to_payment_method, :boolean
    field :hold_in_escrow, :boolean
    field :skip_advanced_fraud_checking, :boolean
    field :skip_avs, :boolean
    field :store_in_vault, :boolean
    field :store_in_vault_on_success, :boolean
    field :store_shipping_address_in_vault, :boolean
    field :submit_for_settlement, :boolean
    field :paypal, :transaction_paypal_type
  end

  input_object :transaction_paypal_type do
    field :custom_field, :string
    field :description, :string
  end

  input_object :custom_fields_type do
    field :donation_slugs, list_of(:string)
    field :tip_percentage, :float
  end

  input_object :donation_get_type do
    field :valid_from, :datetime
    field :valid_to, :datetime
  end

  input_object :merchant_account_get_type do
    field :branch_id, non_null(:integer)
    field :merchant_account_id, non_null(:string)
  end

  input_object :merchant_account_input_type do
    field :branch_id, non_null(:integer)
    field :primary, :boolean
    field :master_merchant_account_id, :string
    field :tos_accepted, :boolean
    field :business, :merchant_business_type
    field :currency_iso_code, :string
    field :default, :boolean
    field :funding, :funding_type
    field :individual, :individual_type
    field :status, :string
  end

  input_object :merchant_account_update_type do
    field :branch_id, non_null(:integer)
    field :merchant_account_id, non_null(:string)
    field :primary, :boolean
    field :master_merchant_account_id, :string
    field :tos_accepted, :boolean
    field :business, :merchant_business_type
    field :currency_iso_code, :string
    field :default, :boolean
    field :funding, :funding_type
    field :individual, :individual_type
    field :status, :string
  end

  input_object :merchant_business_type do
    field :address, :merchant_address_type
    field :dba_name, :string
    field :legal_name, :string
    field :tax_id, :string
  end

  input_object :merchant_address_type do
    field :locality, :string
    field :postal_code, :string
    field :region, :string
    field :street_address, :string
  end

  input_object :funding_type do
    field :account_number, :string
    field :descriptor, :string
    field :destination, :string
    field :email, :string
    field :mobile_pohone, :string
    field :routing_number, :string
  end

  input_object :individual_type do
    field :address, :merchant_address_type
    field :date_of_birth, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :pohone, :string
    field :ssn_last_4, :string
  end

  input_object :credit_card_verification_input_type do
    field :billing_address_details_postal_code, :string
    field :created_at, :string
    field :credit_card_card_type, list_of(:string)
    field :credit_card_cardholder_name, :string
    field :credit_card_expiration_date, :string
    field :credit_card_number, :string
    field :customer_email, :string
    field :customer_id, :string
    field :payment_method_token, :string
  end

  input_object :subscription_get_type do
    field :business_id, non_null(:integer)
    field :options, :subscription_options_type
  end

  input_object :subscription_get_by_type do
    field :status, :string
    field :plan_id, non_null(:string)
    field :options, :subscription_options_type
  end

  input_object :brain_tree_subscription_retry_charge_type do
    field :business_id, non_null(:integer)
    field :submit_for_settlement, :boolean
    #    field :options, :subscription_options_type
  end

  input_object :subscription_cancel_type do
    field :business_id, non_null(:integer)
    #    field :options, :subscription_options_type
  end

  input_object :subscription_input_type do
    field :business_id, non_null(:integer)
    field :password, :string
    field :customer_id, :string
    field :payment_method_id, non_null(:string)
    field :add_ons, :add_on_type
    field :billing_day_of_month, :integer
    field :descriptor, :descriptor_type
    field :discounts, :discount_type
    field :first_billing_date, :date
    field :id, :string
    field :merchant_account_id, :string
    field :never_expires, :boolean
    field :number_of_billing_cycles, :integer
    field :options, :subscription_options_type
    field :payment_method_nonce, :string
    field :payment_method_token, :string
    field :plan_id, non_null(:string)
    field :price, :integer
    field :trial_duration, :integer
    field :trial_duration_unit, :string
    field :trial_period, :boolean
  end

  input_object :subscription_update_type do
    field :business_id, non_null(:integer)
    field :customer_id, :string
    field :add_ons, :add_on_type
    #    field :billing_day_of_month, :integer
    field :descriptor, :descriptor_type
    field :discounts, :discount_type
    #    field :first_billing_date, :string
    field :merchant_account_id, :string
    field :never_expires, :boolean
    field :number_of_billing_cycles, :integer
    field :options, :subscription_options_type
    field :payment_method_nonce, :string
    field :payment_method_token, :string
    field :plan_id, :string
    field :price, :integer
    #    field :trial_duration, :integer
    #    field :trial_duration_unit, :string
    #    field :trial_period, :boolean
  end

  input_object :add_on_type do
    field :add, list_of(:add_ons_add_type)
    field :update, list_of(:add_ons_update_remove_type)
    field :remove, list_of(:add_ons_update_remove_type)
  end

  input_object :discount_type do
    field :add, list_of(:add_ons_add_type)
    field :update, list_of(:add_ons_update_remove_type)
    field :remove, list_of(:add_ons_update_remove_type)
  end

  input_object :descriptor_type do
    field :name, :string
    field :phone, :string
    field :url, :string
  end

  input_object :subscription_options_type do
    field :do_not_inherit_Add_ons_or_Discounts, :boolean
    field :start_immediately, :boolean
    field :paypal, :subscription_paypal_options_type
  end

  input_object :add_ons_add_type do
    field :amount, :string
    field :inherited_from_id, non_null(:string)
    field :never_expires, :boolean
    field :number_of_billing_cycles, :string
    field :quantity, :integer
  end

  input_object :add_ons_update_remove_type do
    field :amount, :string
    field :existing_id, non_null(:string)
    field :never_expires, :boolean
    field :number_of_billing_cycles, :string
    field :quantity, :integer
  end

  input_object :subscription_paypal_options_type do
    field :description, :string
  end

  input_object :subscription_bsp_rule_input_type do
    field :package_id, non_null(:string)
    field :slug, non_null(:string)
    field :consumer_family_member, :boolean
    field :data_privacy, :boolean
    field :n_ter, :boolean
    field :tenant_business_providers, :integer
    field :data_retention, :integer
    field :data_unit, non_null(:string)
    field :package_validity, non_null(:string)
    field :time_unit, non_null(:string)
    field :package_monthly_price, :float
    field :package_annual_price, :float
    field :payment_with_applied_fee, :boolean
    field :allow_additional_employee, :boolean
    field :allow_additional_branch_office, :boolean
    field :allow_additional_tenant_business, :boolean
    field :allow_additional_promotion, non_null(:boolean)
    field :allow_additional_job_posting, :boolean
    field :promotion_validity, non_null(:integer)
    field :additional_employee_charges, :float
    field :reports_period, :integer
    field :additional_promotion_charges, :float
    field :additional_job_posting_charges, :float
    field :bus_net, :boolean
    field :deals, :boolean
    field :employees_count, :integer
    field :business_private_messaging, :boolean
    field :branch_offices, :integer
    field :consumer_private_messaging, :boolean
    field :consolidated_calendar, :boolean
    field :data_limit, non_null(:integer)
    field :business_verification, :boolean
    field :promotions, non_null(:integer)
    field :job_search_apply, :boolean
    field :job_posting_validity, :integer
    field :additional_tenant_business_charges, :float
    field :tudo_portion_of_consumer_tip, :integer
    field :package_name, non_null(:string)
    field :additional_branch_office_charges, :float
    field :job_postings, :integer
    field :tasks_events, :boolean
    field :show_adds, :boolean
    field :service_appointments, :string
    field :my_net, :boolean
    field :country_id, :integer
  end

  input_object :subscription_bsp_rule_update_type do
    field :id, non_null(:integer)
    field :slug, :string
    field :consumer_family_member, :boolean
    field :data_privacy, :boolean
    field :n_ter, :boolean
    field :tenant_business_providers, :integer
    field :data_retention, :integer
    field :package_validity, :string
    field :data_unit, :string
    field :time_unit, :string
    field :package_monthly_price, :float
    field :package_annual_price, :float
    field :payment_with_applied_fee, :boolean
    field :allow_additional_employee, :boolean
    field :allow_additional_branch_office, :boolean
    field :allow_additional_tenant_business, :boolean
    field :allow_additional_promotion, :boolean
    field :allow_additional_job_posting, :boolean
    field :promotion_validity, :integer
    field :additional_employee_charges, :float
    field :reports_period, :integer
    field :additional_promotion_charges, :float
    field :additional_job_posting_charges, :float
    field :bus_net, :boolean
    field :deals, :boolean
    field :employees_count, :integer
    field :business_private_messaging, :boolean
    field :branch_offices, :integer
    field :consumer_private_messaging, :boolean
    field :consolidated_calendar, :boolean
    field :data_limit, :integer
    field :business_verification, :boolean
    field :promotions, :integer
    field :package_id, :string
    field :job_search_apply, :boolean
    field :job_posting_validity, :integer
    field :additional_tenant_business_charges, :float
    field :tudo_portion_of_consumer_tip, :integer
    field :package_name, :string
    field :additional_branch_office_charges, :float
    field :job_postings, :integer
    field :tasks_events, :boolean
    field :show_adds, :boolean
    field :service_appointments, :string
    field :my_net, :boolean
    field :country_id, :integer
  end

  input_object :subscription_bsp_rule_get_by_type do
    field :slug, non_null(:string)
    field :country_id, non_null(:integer)
  end

  input_object :subscription_bsp_rule_get_type do
    field :id, non_null(:integer)
  end

  input_object :subscription_bsp_rule_get_by_country_type do
    field :country_id, non_null(:integer)
  end

  input_object :paypal_account_get_type do
    field :branch_id, non_null(:integer)
  end

  input_object :brain_tree_address_input_type do
    field :user_id, non_null(:integer)
    field :address_id, non_null(:integer)
  end

  input_object :dispute_category_input_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :dispute_category_update_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :dispute_category_get_type do
    field :id, non_null(:id)
  end

  input_object :dispute_status_input_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :dispute_status_update_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :dispute_status_get_type do
    field :id, non_null(:id)
  end

  input_object :bsp_payment_get_type do
    field :branch_id, non_null(:integer)
    field :status_id, non_null(:string)
    field :from, :datetime
    field :to, :datetime
  end

  input_object :cmr_paid_payment_get_type do
    field :from, :datetime
    field :to, :datetime
  end

  input_object :bsp_paid_payment_get_type do
    field :branch_id, :integer
    field :business_id, :integer
  end

  input_object :payment_get_type do
    field :payment_id, non_null(:integer)
  end
end
