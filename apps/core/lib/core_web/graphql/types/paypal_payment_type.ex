defmodule CoreWeb.GraphQL.Types.PaypalPaymentType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :paypal_access_token_type do
    field :access_token, :string
    field :token_type, :string
  end

  object :paypal_access_attribute_type do
    field :id, :string
    field :access_token, :string
    field :partner_attribution_id, :string
    field :expires_in, :integer
    field :expires_after, :string
    field :inserted_at, :string
    field :updated_at, :string
  end

  object :seller_account_type do
    field :id, :integer
    field :default, :boolean
    field :links, list_of(:json)
    field :referral_data, :json
    field :email, :string
    field :partner_referral_id, :string
    field :user, :user_type, resolve: assoc(:user)
    field :token, :string
    field :status, :string
    field :created_on, :string
    field :language, :string
    field :time_zone, :string
    field :profile_type, :string
    field :country, :string
    field :client_user_id, :string
    field :first_name, :string
    field :last_name, :string
    field :date_of_birth, :string
    field :address_line1, :string
    field :city, :string
    field :state_province, :string
    field :postal_code, :string
    field :program_token, :string
    field :business_name, :string
    field :business_type, :string
    field :country_of_birth, :string
    field :country_of_nationality, :string
    field :gender, :string
    field :phone_number, :string
    field :mobile_number, :string
    field :government_id, :string
    field :government_id_type, :string
    field :passport_id, :string
    field :drivers_license_id, :string
    field :employer_id, :string
    field :business_operating_name, :string
    field :business_registration_id, :string
    field :business_registration_state_province, :string
    field :business_registration_country, :string
    field :business_contact_role, :string
    field :business_contact_address_line1, :string
    field :business_contact_address_line2, :string
    field :business_contact_city, :string
    field :business_contact_state_province, :string
    field :business_contact_country, :string
    field :business_contact_postal_code, :string
    field :default_transfer_method_token, :string
  end

  object :paypal_seller_account_type do
    field :links, list_of(:json)
    field :referral_data, :json
    field :partner_referral_id, :string
    field :email, :string
    field :default, :boolean
    field :id, :integer
    field :user, :user_type, resolve: assoc(:user)
  end

  object :paypal_order_type do
    field :id, :string
    field :links, list_of(:json)
    field :payer, :json
    field :purchase_units, list_of(:json)
    field :status, :string
    #    field :subscription_feature_id, :integer
  end

  object :paypal_product_type do
    field :id, :string
    field :name, :string
    field :description, :string
    field :create_time, :string
    field :links, list_of(:json)
  end

  #  object :paypal_plan_type do
  #    field :id, :string
  #    field :product_id, :string
  #    field :name, :string
  #    field :description, :string
  #    field :status, :string
  #    field :create_time, :string
  #    field :links, list_of :json
  #  end

  object :paypal_plan_type do
    field :id, :integer
    field :name, :string
    field :slug, :string
    field :type, :string
    field :active, :boolean
    field :annual_price, :float
    field :monthly_price, :float
    field :currency, :string
    field :paypal_plan_id, :string
    field :plan_discount, :json
    field :cmr_walk_in_appointments, :json
    field :cmr_home_service_appointments, :json
    field :cmr_on_demand_appointments, :json
    field :cmr_data_limit, :json
    field :cmr_data_retention, :json
    field :cmr_calendar, :json
    field :cmr_tasks_events, :json
    field :cmr_my_net, :json
    field :cmr_nter, :json
    field :cmr_family, :json
    field :cmr_deals, :json
    field :cmr_jobs_search, :json
    field :cmr_reports, :json
    field :bsp_walk_in_appointments, :json
    field :bsp_home_service_appointments, :json
    field :bsp_on_demand_appointments, :json
    field :bsp_data_limit, :json
    field :bsp_data_retention, :json
    field :bsp_calendar, :json
    field :bsp_bus_net, :json
    field :bsp_nter, :json
    field :promotions, :json
    field :leads, :json
    field :prospects, :json
    field :job_postings, :json
    field :employees, :json
    field :gratuity, :json
    field :marketing, :json
    field :branches, :json
    field :advance_reports, :json
    field :tenant, :json
    field :events, :json
    field :bid_proposal, :json
    field :e_commerce, :json
    field :warehouse, :json
    field :employee_center, :json
    field :risk_managemment, :json
    field :time_managemment, :json
    field :compensation, :json
    field :recruitment, :json
    field :shopping, :json
    field :accounting, :json
    field :budget_planning, :json
    field :finance_management, :json
    field :supply_chain, :json
    field :restaurant, :json
    field :transportation, :json
    field :event_management, :json
    field :custom_portals, :json
    field :add_on1, :json
    field :add_on2, :json
    field :add_on3, :json
    field :add_on4, :json
    field :add_on5, :json
    field :add_on6, :json
    field :add_on7, :json
    field :add_on8, :json
    field :add_on9, :json
    field :add_on10, :json
    field :add_on11, :json
    field :add_on12, :json
    field :add_on13, :json
    field :add_on14, :json
    field :add_on15, :json
    field :add_on16, :json
    field :add_on17, :json
    field :add_on18, :json
    field :add_on19, :json
    field :add_on20, :json
    field :country, :country_type, resolve: assoc(:country)
  end

  #  for listing by country
  object :paypal_featured_plan_type do
    field :id, :integer
    field :name, :string
    field :slug, :string
    field :type, :string
    field :active, :boolean
    field :annual_price, :float
    field :monthly_price, :float
    field :currency, :string
    field :paypal_plan_id, :string
    field :plan_discount, :json
    field :cmr_common_features, :cmr_common_features_type
    field :bsp_common_features, :bsp_common_features_type
    field :promotions, :json
    field :leads, :json
    field :prospects, :json
    field :job_postings, :json
    field :employees, :json
    field :gratuity, :json
    field :marketing, :json
    field :branches, :json
    field :advance_reports, :json
    field :tenant, :json
    field :events, :json
    field :bid_proposal, :json
    field :e_commerce, :json
    field :warehouse, :json
    field :employee_center, :json
    field :risk_managemment, :json
    field :time_managemment, :json
    field :compensation, :json
    field :recruitment, :json
    field :shopping, :json
    field :accounting, :json
    field :budget_planning, :json
    field :finance_management, :json
    field :supply_chain, :json
    field :restaurant, :json
    field :transportation, :json
    field :event_management, :json
    field :custom_portals, :json
    field :add_on1, :json
    field :add_on2, :json
    field :add_on3, :json
    field :add_on4, :json
    field :add_on5, :json
    field :add_on6, :json
    field :add_on7, :json
    field :add_on8, :json
    field :add_on9, :json
    field :add_on10, :json
    field :add_on11, :json
    field :add_on12, :json
    field :add_on13, :json
    field :add_on14, :json
    field :add_on15, :json
    field :add_on16, :json
    field :add_on17, :json
    field :add_on18, :json
    field :add_on19, :json
    field :add_on20, :json
    field :country, :country_type, resolve: assoc(:country)
  end

  object :cmr_common_features_type do
    field :cmr_walk_in_appointments, :json
    field :cmr_home_service_appointments, :json
    field :cmr_on_demand_appointments, :json
    field :cmr_data_limit, :json
    field :cmr_data_retention, :json
    field :cmr_calendar, :json
    field :cmr_tasks_events, :json
    field :cmr_my_net, :json
    field :cmr_nter, :json
    field :cmr_family, :json
    field :cmr_deals, :json
    field :cmr_jobs_search, :json
    field :cmr_reports, :json
  end

  object :bsp_common_features_type do
    field :bsp_walk_in_appointments, :json
    field :bsp_home_service_appointments, :json
    field :bsp_on_demand_appointments, :json
    field :bsp_data_limit, :json
    field :bsp_data_retention, :json
    field :bsp_calendar, :json
    field :bsp_bus_net, :json
    field :bsp_nter, :json
  end

  object :paypal_subscription_type do
    field :id, :string
    field :status_id, :string
    field :plan_id, :string
    field :create_time, :datetime
    field :start_date, :date
    field :annual, :boolean
    field :expiry_date, :date
    field :links, list_of(:json)
    field :name, :string
    field :slug, :string
    field :active, :boolean
    field :annual_price, :float
    field :monthly_price, :float
    field :currency, :string
    field :paypal_plan_id, :string
    field :subscription_plan_id, :integer
    field :plan_discount, :json
    field :cmr_walk_in_appointments, :json
    field :next_billing_period_date, :date
    field :next_billing_period_amount, :integer
    field :current_billing_cycle, :integer
    field :cmr_home_service_appointments, :json
    field :cmr_on_demand_appointments, :json
    field :cmr_data_limit, :json
    field :cmr_data_retention, :json
    field :cmr_calendar, :json
    field :cmr_tasks_events, :json
    field :cmr_my_net, :json
    field :cmr_nter, :json
    field :cmr_family, :json
    field :cmr_deals, :json
    field :cmr_jobs_search, :json
    field :cmr_reports, :json
    field :bsp_walk_in_appointments, :json
    field :bsp_home_service_appointments, :json
    field :bsp_on_demand_appointments, :json
    field :bsp_data_limit, :json
    field :bsp_data_retention, :json
    field :bsp_calendar, :json
    field :bsp_bus_net, :json
    field :bsp_nter, :json
    field :promotions, :json
    field :leads, :json
    field :prospects, :json
    field :job_postings, :json
    field :employees, :json
    field :gratuity, :json
    field :marketing, :json
    field :branches, :json
    field :advance_reports, :json
    field :tenant, :json
    field :events, :json
    field :bid_proposal, :json
    field :e_commerce, :json
    field :warehouse, :json
    field :employee_center, :json
    field :risk_managemment, :json
    field :time_managemment, :json
    field :compensation, :json
    field :recruitment, :json
    field :shopping, :json
    field :accounting, :json
    field :budget_planning, :json
    field :finance_management, :json
    field :supply_chain, :json
    field :restaurant, :json
    field :transportation, :json
    field :event_management, :json
    field :custom_portals, :json
    field :add_on1, :json
    field :add_on2, :json
    field :add_on3, :json
    field :add_on4, :json
    field :add_on5, :json
    field :add_on6, :json
    field :add_on7, :json
    field :add_on8, :json
    field :add_on9, :json
    field :add_on10, :json
    field :add_on11, :json
    field :add_on12, :json
    field :add_on13, :json
    field :add_on14, :json
    field :add_on15, :json
    field :add_on16, :json
    field :add_on17, :json
    field :add_on18, :json
    field :add_on19, :json
    field :add_on20, :json
    field :country, :country_type, resolve: assoc(:country)
    field :business, :business_type, resolve: assoc(:business)
  end

  input_object :user_subscription_input_type do
    field :user_id, non_null(:integer)
  end

  input_object :seller_account_input_type do
    field :paypal_account, :paypal_seller_account_input_type
    field :hyper_wallet_account, :hyper_wallet_user_input_type
  end

  input_object :paypal_seller_account_input_type do
    field :access_token, :string
    field :tracking_id, :string
    field :email, non_null(:string)
    field :default, :boolean
    #    field :to_be_created, :boolean
    field :preferred_language_code, :string
    #    field :partner_config_override, :partner_config_override_type
    field :products, list_of(:string)
    field :phones, list_of(:phone_type)
    field :website, :string
    #    field :addresses, list_of :address_type
    field :legal_consents, list_of(:legal_consents_type)
    field :operations, :string
    field :password, :string
  end

  input_object :paypal_seller_account_update_type do
    field :id, non_null(:integer)
    field :default, non_null(:boolean)
    field :password, :string
  end

  input_object :paypal_seller_account_delete_type do
    field :id, non_null(:integer)
    field :password, :string
  end

  input_object :legal_consents_type do
    field :type, non_null(:string)
    field :granted, non_null(:boolean)
  end

  input_object :phone_type do
    field :country_code, non_null(:string)
    field :national_number, non_null(:string)
    field :extension_number, :string
    field :type, :string
  end

  input_object :paypal_order_input_type do
    field :access_token, :string
    #    field :intent, :string
    field :payer, :payer_input_type
    field :description, :string
    field :soft_descriptor, :string
    field :items, :string
    field :shipping, :string
    field :amount, non_null(:float)
    #    local
    field :payment_method_id, non_null(:string)
    field :payable_amount, :float
    field :password, :string
    field :get_insured, :boolean
    # job payments
    field :job_id, :integer
    field :order_id, :integer
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
    #    field :purchase_units, list_of :purchase_units_input_type
  end

  input_object :purchase_units_input_type do
    field :amount, :amount_input_type
    field :payee, :payee_input_type
  end

  input_object :payer_input_type do
    field :email_address, :string
  end

  input_object :payee_input_type do
    field :email_address, :string
  end

  input_object :amount_input_type do
    field :value, non_null(:string)
    field :currency_code, non_null(:string)
  end

  input_object :action_on_paypal_order_input_type do
    field :paypal_order_id, non_null(:string)
    field :job_id, :integer
    field :product_order_id, :integer
    field :cash_payment_id, :integer
    field :promotion_pricing_id, :integer
    field :subscription_feature_slug, :string
    field :password, :string
  end

  input_object :authorize_payment_input_type do
    field :paypal_order_id, :string
    field :product_order_id, :integer
  end

  # input_object :disburse_paypal_order_input_type do
  #    field :reference_id, non_null :string
  #  end

  input_object :paypal_payout_input_type do
    field :amount, non_null(:float)
    field :branch_id, non_null(:integer)
    field :seller_id, :integer
  end

  input_object :paypal_product_input_type do
    field :name, non_null(:string)
    field :description, :string
    field :type, non_null(:string)
    field :category, :string
    field :image_url, :string
    field :home_url, :string
  end

  input_object :paypal_plan_input_type do
    # required
    field :name, :string
    # required
    field :slug, :string
    # required
    field :type, :string
    field :active, :boolean
    field :annual_price, :float
    field :monthly_price, :float
    field :currency, :string
    field :plan_discount, :plan_discount_input_type
    field :cmr_walk_in_appointments, :plan_featurte_input_type
    field :cmr_home_service_appointments, :plan_featurte_input_type
    field :cmr_on_demand_appointments, :plan_featurte_input_type
    field :cmr_bids, :plan_featurte_input_type
    field :cmr_data_limit, :plan_featurte_input_type
    field :cmr_data_retention, :plan_featurte_input_type
    field :cmr_calendar, :plan_featurte_input_type
    field :cmr_tasks_events, :plan_featurte_input_type
    field :cmr_my_net, :plan_featurte_input_type
    field :cmr_nter, :plan_featurte_input_type
    field :cmr_family, :plan_featurte_input_type
    field :cmr_deals, :plan_featurte_input_type
    field :cmr_jobs_search, :plan_featurte_input_type
    field :cmr_reports, :plan_featurte_input_type
    field :bsp_walk_in_appointments, :plan_featurte_input_type
    field :bsp_home_service_appointments, :plan_featurte_input_type
    field :bsp_on_demand_appointments, :plan_featurte_input_type
    field :bsp_data_limit, :plan_featurte_input_type
    field :bsp_data_retention, :plan_featurte_input_type
    field :bsp_calendar, :plan_featurte_input_type
    field :bsp_bus_net, :plan_featurte_input_type
    field :bsp_nter, :plan_featurte_input_type
    field :promotions, :plan_featurte_input_type
    field :leads, :plan_featurte_input_type
    field :prospects, :plan_featurte_input_type
    field :job_postings, :plan_featurte_input_type
    field :employees, :plan_featurte_input_type
    field :branches, :plan_featurte_input_type
    field :advance_reports, :plan_featurte_input_type
    field :tenant, :plan_featurte_input_type
    field :events, :plan_featurte_input_type
    field :bid_proposal, :plan_featurte_input_type
    field :e_commerce, :plan_featurte_input_type
    field :warehouse, :plan_featurte_input_type
    field :employee_center, :plan_featurte_input_type
    field :risk_managemment, :plan_featurte_input_type
    field :time_managemment, :plan_featurte_input_type
    field :compensation, :plan_featurte_input_type
    field :recruitment, :plan_featurte_input_type
    field :shopping, :plan_featurte_input_type
    field :accounting, :plan_featurte_input_type
    field :budget_planning, :plan_featurte_input_type
    field :finance_management, :plan_featurte_input_type
    field :supply_chain, :plan_featurte_input_type
    field :restaurant, :plan_featurte_input_type
    field :transportation, :plan_featurte_input_type
    field :event_management, :plan_featurte_input_type
    field :custom_portals, :plan_featurte_input_type
    field :gratuity, :plan_featurte_input_type
    field :marketing, :plan_featurte_input_type
    field :add_on1, :plan_featurte_input_type
    field :add_on2, :plan_featurte_input_type
    field :add_on3, :plan_featurte_input_type
    field :add_on4, :plan_featurte_input_type
    field :add_on5, :plan_featurte_input_type
    field :add_on6, :plan_featurte_input_type
    field :add_on7, :plan_featurte_input_type
    field :add_on8, :plan_featurte_input_type
    field :add_on9, :plan_featurte_input_type
    field :add_on10, :plan_featurte_input_type
    field :add_on11, :plan_featurte_input_type
    field :add_on12, :plan_featurte_input_type
    field :add_on13, :plan_featurte_input_type
    field :add_on14, :plan_featurte_input_type
    field :add_on15, :plan_featurte_input_type
    field :add_on16, :plan_featurte_input_type
    field :add_on17, :plan_featurte_input_type
    field :add_on18, :plan_featurte_input_type
    field :add_on19, :plan_featurte_input_type
    field :add_on20, :plan_featurte_input_type
    field :country_id, :integer
  end

  input_object :paypal_plan_update_type do
    field :id, non_null(:integer)
    field :name, :string
    field :slug, :string
    field :type, :string
    field :active, :boolean
    field :annual_price, :float
    field :monthly_price, :float
    field :currency, :string
    field :plan_discount, :plan_discount_input_type
    field :cmr_walk_in_appointments, :plan_featurte_input_type
    field :cmr_home_service_appointments, :plan_featurte_input_type
    field :cmr_on_demand_appointments, :plan_featurte_input_type
    field :cmr_bids, :plan_featurte_input_type
    field :cmr_data_limit, :plan_featurte_input_type
    field :cmr_data_retention, :plan_featurte_input_type
    field :cmr_calendar, :plan_featurte_input_type
    field :cmr_tasks_events, :plan_featurte_input_type
    field :cmr_my_net, :plan_featurte_input_type
    field :cmr_nter, :plan_featurte_input_type
    field :cmr_family, :plan_featurte_input_type
    field :cmr_deals, :plan_featurte_input_type
    field :cmr_jobs_search, :plan_featurte_input_type
    field :cmr_reports, :plan_featurte_input_type
    field :bsp_walk_in_appointments, :plan_featurte_input_type
    field :bsp_home_service_appointments, :plan_featurte_input_type
    field :bsp_on_demand_appointments, :plan_featurte_input_type
    field :bsp_data_limit, :plan_featurte_input_type
    field :bsp_data_retention, :plan_featurte_input_type
    field :bsp_calendar, :plan_featurte_input_type
    field :bsp_bus_net, :plan_featurte_input_type
    field :bsp_nter, :plan_featurte_input_type
    field :promotions, :plan_featurte_input_type
    field :leads, :plan_featurte_input_type
    field :prospects, :plan_featurte_input_type
    field :job_postings, :plan_featurte_input_type
    field :employees, :plan_featurte_input_type
    field :gratuity, :plan_featurte_input_type
    field :marketing, :plan_featurte_input_type
    field :branches, :plan_featurte_input_type
    field :advance_reports, :plan_featurte_input_type
    field :tenant, :plan_featurte_input_type
    field :events, :plan_featurte_input_type
    field :bid_proposal, :plan_featurte_input_type
    field :e_commerce, :plan_featurte_input_type
    field :warehouse, :plan_featurte_input_type
    field :employee_center, :plan_featurte_input_type
    field :risk_managemment, :plan_featurte_input_type
    field :time_managemment, :plan_featurte_input_type
    field :compensation, :plan_featurte_input_type
    field :recruitment, :plan_featurte_input_type
    field :shopping, :plan_featurte_input_type
    field :accounting, :plan_featurte_input_type
    field :budget_planning, :plan_featurte_input_type
    field :finance_management, :plan_featurte_input_type
    field :supply_chain, :plan_featurte_input_type
    field :restaurant, :plan_featurte_input_type
    field :transportation, :plan_featurte_input_type
    field :event_management, :plan_featurte_input_type
    field :custom_portals, :plan_featurte_input_type
    field :add_on1, :plan_featurte_input_type
    field :add_on2, :plan_featurte_input_type
    field :add_on3, :plan_featurte_input_type
    field :add_on4, :plan_featurte_input_type
    field :add_on5, :plan_featurte_input_type
    field :add_on6, :plan_featurte_input_type
    field :add_on7, :plan_featurte_input_type
    field :add_on8, :plan_featurte_input_type
    field :add_on9, :plan_featurte_input_type
    field :add_on10, :plan_featurte_input_type
    field :add_on11, :plan_featurte_input_type
    field :add_on12, :plan_featurte_input_type
    field :add_on13, :plan_featurte_input_type
    field :add_on14, :plan_featurte_input_type
    field :add_on15, :plan_featurte_input_type
    field :add_on16, :plan_featurte_input_type
    field :add_on17, :plan_featurte_input_type
    field :add_on18, :plan_featurte_input_type
    field :add_on19, :plan_featurte_input_type
    field :add_on20, :plan_featurte_input_type
    field :country_id, :integer
  end

  input_object :paypal_plan_get_type do
    field :country_id, non_null(:integer)
  end

  input_object :plan_featurte_input_type do
    field :name, :string
    field :title, :string
    field :type, :string
    field :included, :boolean
    field :available, :boolean
    field :limit, :string
    field :monthly_limit, :integer
    field :annual_limit, :integer
    field :unit_of_measure, :string
    field :unit_price, :float
    field :lot_size, :float
    field :lot_discount, :float
    field :active, :boolean
    field :details, :string
    field :instructions, :string
  end

  input_object :plan_discount_input_type do
    field :title, :string
    field :discount_percentage, :float
    field :begin_date, :datetime
    field :end_date, :datetime
    field :details, :string
    field :instructions, :string
  end

  input_object :paypal_plan_get_by_country_type do
    field :country_id, non_null(:integer)
    field :type, :string
  end

  input_object :paypal_subscription_input_type do
    #    field :cashfree_plan_id, :string
    field :subscription_plan_id, non_null(:integer)
    field :business_id, non_null(:integer)
    field :country_id, non_null(:integer)
    field :annual, non_null(:boolean)
    field :payment_method_id, non_null(:string)

    field :access_token, :string
    field :cycles_count, :integer
    field :plan_discount, :plan_discount_input_type
    field :cmr_walk_in_appointments, :each_node_custom_input_type
    field :cmr_home_service_appointments, :each_node_custom_input_type
    field :cmr_on_demand_appointments, :each_node_custom_input_type
    field :cmr_bids, :each_node_custom_input_type
    field :cmr_data_limit, :each_node_custom_input_type
    field :cmr_data_retention, :each_node_custom_input_type
    field :cmr_calendar, :each_node_custom_input_type
    field :cmr_tasks_events, :each_node_custom_input_type
    field :cmr_my_net, :each_node_custom_input_type
    field :cmr_nter, :each_node_custom_input_type
    field :cmr_family, :each_node_custom_input_type
    field :cmr_deals, :each_node_custom_input_type
    field :cmr_jobs_search, :each_node_custom_input_type
    field :cmr_reports, :each_node_custom_input_type
    field :bsp_walk_in_appointments, :each_node_custom_input_type
    field :bsp_home_service_appointments, :each_node_custom_input_type
    field :bsp_on_demand_appointments, :each_node_custom_input_type
    field :bsp_data_limit, :each_node_custom_input_type
    field :bsp_data_retention, :each_node_custom_input_type
    field :bsp_calendar, :each_node_custom_input_type
    field :bsp_bus_net, :each_node_custom_input_type
    field :bsp_nter, :each_node_custom_input_type
    field :promotions, :each_node_custom_input_type
    field :leads, :each_node_custom_input_type
    field :prospects, :each_node_custom_input_type
    field :job_postings, :each_node_custom_input_type
    field :employees, :each_node_custom_input_type
    field :branches, :each_node_custom_input_type
    field :advance_reports, :each_node_custom_input_type
    field :tenant, :each_node_custom_input_type
    field :events, :each_node_custom_input_type
    field :bid_proposal, :each_node_custom_input_type
    field :e_commerce, :each_node_custom_input_type
    field :warehouse, :each_node_custom_input_type
    field :employee_center, :each_node_custom_input_type
    field :risk_managemment, :each_node_custom_input_type
    field :time_managemment, :each_node_custom_input_type
    field :compensation, :each_node_custom_input_type
    field :recruitment, :each_node_custom_input_type
    field :shopping, :each_node_custom_input_type
    field :accounting, :each_node_custom_input_type
    field :budget_planning, :each_node_custom_input_type
    field :finance_management, :each_node_custom_input_type
    field :supply_chain, :each_node_custom_input_type
    field :restaurant, :each_node_custom_input_type
    field :transportation, :each_node_custom_input_type
    field :event_management, :each_node_custom_input_type
    field :custom_portals, :each_node_custom_input_type
    field :gratuity, :each_node_custom_input_type
    field :marketing, :each_node_custom_input_type
    field :add_on1, :each_node_custom_input_type
    field :add_on2, :each_node_custom_input_type
    field :add_on3, :each_node_custom_input_type
    field :add_on4, :each_node_custom_input_type
    field :add_on5, :each_node_custom_input_type
    field :add_on6, :each_node_custom_input_type
    field :add_on7, :each_node_custom_input_type
    field :add_on8, :each_node_custom_input_type
    field :add_on9, :each_node_custom_input_type
    field :add_on10, :each_node_custom_input_type
    field :add_on11, :each_node_custom_input_type
    field :add_on12, :each_node_custom_input_type
    field :add_on13, :each_node_custom_input_type
    field :add_on14, :each_node_custom_input_type
    field :add_on15, :each_node_custom_input_type
    field :add_on16, :each_node_custom_input_type
    field :add_on17, :each_node_custom_input_type
    field :add_on18, :each_node_custom_input_type
    field :add_on19, :each_node_custom_input_type
    field :add_on20, :each_node_custom_input_type
    field :subscriber, :payer_input_type
    field :price, :float
    field :start_time, :datetime
    field :shipping_amount, :amount_input_type
    field :application_context, list_of(:application_context_input_type)
    #    field :plan, :custom_plan_input_type     #for plan over riding
  end

  input_object :paypal_subscription_update_type do
    field :status_id, non_null(:string)
    field :business_id, non_null(:integer)
  end

  input_object :paypal_subscription_get_by_business_type do
    field :business_id, non_null(:integer)
  end

  input_object :each_node_custom_input_type do
    field :quantity, non_null(:integer)
  end

  input_object :custom_plan_input_type do
    field :payment_preferences, :payment_preferences_input_type
    field :billing_cycles, list_of(:plan_override_billing_cycles_input_type)
  end

  input_object :billing_cycles_input_type do
    field :pricing_scheme, :pricing_scheme_input_type
    field :frequency, non_null(:frequency_input_type)
    field :tenure_type, non_null(:string)
    field :sequence, :integer
    field :total_cycles, :integer
  end

  input_object :plan_override_billing_cycles_input_type do
    field :pricing_scheme, :pricing_scheme_input_type
    field :sequence, :integer
    field :total_cycles, :integer
  end

  input_object :frequency_input_type do
    field :interval_unit, :string
    field :interval_count, :integer
  end

  input_object :pricing_scheme_input_type do
    field :version, :integer
    field :fixed_price, :amount_input_type
  end

  input_object :payment_preferences_input_type do
    field :auto_bill_outstanding, :boolean
    field :setup_fee, :amount_input_type
    field :setup_fee_failure_action, :string
    field :payment_failure_threshold, :integer
  end

  input_object :application_context_input_type do
    field :brand_name, :string
    field :locale, :string
    field :shipping_preference, :string
    field :user_action, :string
    field :payment_method, :paypal_payment_method_input_type
    field :return_url, :string
    field :cancel_url, :string
  end

  input_object :paypal_payment_method_input_type do
    field :payer_selected, :string
    field :payee_preferred, :string
  end
end
