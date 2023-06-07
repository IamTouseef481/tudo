defmodule CoreWeb.GraphQL.Types.HyperWalletPaymentType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :hyper_wallet_user_type do
    field :id, :integer
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
    field :email, :string
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
    #    field :user, :user_type, resolve: assoc(:user)
    #    field :branch, :branch_type, resolve: assoc(:branch)
  end

  object :hyper_wallet_transfer_method_type do
    field :id, :integer
    field :is_default, :boolean
    field :type, :string
    field :transfer_method_country, :string
    field :transfer_method_currency, :string
    #    for bank account and also common for all methods
    field :token, :string
    field :status, :string
    field :created_on, :string
    #    for bank account
    field :branch_id, :string
    field :bank_account_id, :string
    field :bank_account_purpose, :string
    field :profile_type, :string
    field :first_name, :string
    field :last_name, :string
    field :date_of_birth, :string
    field :address_line1, :string
    field :city, :string
    field :state_province, :string
    field :country, :string
    field :postal_code, :string
    #    for bank card
    field :card_type, :string
    field :card_number, :string
    field :card_brand, :string
    field :date_of_expiry, :string
    field :processing_time, :string
    #    for paypal account
    field :email, :string
    #    for venmo account
    field :account_id, :string
    #    field :user, :user_type, resolve: assoc(:user)
    #    field :branch, :branch_type, resolve: assoc(:branch)
  end

  object :hyper_wallet_transaction_type do
    field :id, :integer
    field :hyperwallet_fee, :float
    field :token, :string
    field :status, :string
    field :amount, :float
    field :transfer_at, :datetime
    field :created_on, :string
    field :currency, :string
    field :client_payment_id, :string
    field :purpose, :string
    field :expires_on, :string
    field :destination_token, :string
    field :program_token, :string
    field :user, :user_type, resolve: assoc(:user)
    field :branch, :branch_type, resolve: assoc(:branch)
  end

  object :hyper_wallet_transfer_type do
    field :id, :integer
    field :token, :string
    field :status, :string
    field :created_on, :string
    field :source_amount, :string
    field :client_transfer_id, :string
    field :source_token, :string
    field :source_currency, :string
    field :destination_token, :string
    field :destination_amount, :string
    field :destination_currency, :string
    field :foreign_exchanges, list_of(:json)
    field :expires_on, :string
    field :memo, :string
    field :notes, :string
  end

  object :hyper_wallet_transfer_method_fields_type do
    field :type, :string
    field :countries, list_of(:string)
    field :currencies, list_of(:string)
    field :fields, list_of(:json)
    field :profile_type, :string
  end

  object :hyper_wallet_currencies_type do
    field :types, list_of(:string)
    field :country, :string
    field :currency, :string
  end

  input_object :hyper_wallet_user_input_type do
    field :profile_type, non_null(:string)
    field :country, non_null(:string)
    field :client_user_id, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :email, non_null(:string)
    field :date_of_birth, non_null(:string)
    field :address_line1, non_null(:string)
    field :address_line2, :string
    field :city, non_null(:string)
    field :state_province, non_null(:string)
    field :postal_code, non_null(:integer)
    field :business_name, non_null(:string)
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
    field :language, :string
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
    #    field :program_token, non_null :string
    #    field :hyper_wallet_account_user_name, non_null :string
    #    field :hyper_wallet_account_password, non_null :string
  end

  input_object :hyper_wallet_user_update_type do
    field :profile_type, :string
    field :country, :string
    field :client_user_id, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :date_of_birth, :date
    field :address_line1, :string
    field :address_line2, :string
    field :city, :string
    field :state_province, :string
    field :postal_code, :integer
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
    field :language, :string
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
    #    field :program_token, non_null :string
    #    field :hyper_wallet_account_user_name, non_null :string
    #    field :hyper_wallet_account_password, non_null :string
  end

  input_object :hyper_wallet_transfer_method_input_type do
    field :type, non_null(:string)
    field :transfer_method_country, non_null(:string)
    field :transfer_method_currency, non_null(:string)
    field :profile_type, :string
    field :is_default, :boolean
    field :params, non_null(:string)

    #    field :bank_account, :hyper_wallet_bank_account_input_type
    #    field :bank_card, :hyper_wallet_bank_card_input_type
    #    field :paypal_account, :hyper_wallet_paypal_account_input_type
    #    field :venmo_account, :hyper_wallet_venmo_account_input_type

    #    field :hyper_wallet_account_user_name, non_null :string
    #    field :hyper_wallet_account_password, non_null :string
  end

  input_object :hyper_wallet_transfer_method_update_type do
    field :is_default, :boolean
    field :transfer_method_id, non_null(:integer)
    field :params, :string
    #    field :bank_account, :hyper_wallet_bank_account_update_type
    #    field :bank_card, :hyper_wallet_bank_card_update_type
    #    field :paypal_account, :hyper_wallet_paypal_account_update_type
    #    field :venmo_account, :hyper_wallet_venmo_account_update_type

    #    field :hyper_wallet_account_user_name, non_null :string
    #    field :hyper_wallet_account_password, non_null :string
  end

  input_object :hyper_wallet_bank_account_input_type do
    field :profile_type, non_null(:string)
    field :branch_id, non_null(:integer)
    field :bank_account_id, non_null(:integer)
    field :bank_account_purpose, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :country, non_null(:string)
    field :address_line1, non_null(:string)
    field :city, non_null(:string)
    field :state_province, non_null(:string)
    field :postal_code, non_null(:string)
  end

  input_object :hyper_wallet_bank_account_update_type do
    field :profile_type, :string
    field :branch_id, :integer
    field :bank_account_id, :integer
    field :bank_account_purpose, :string
    field :first_name, :string
    field :last_name, :string
    field :country, :string
    field :address_line1, :string
    field :city, :string
    field :state_province, :string
    field :postal_code, :string
  end

  input_object :hyper_wallet_bank_card_input_type do
    field :card_number, non_null(:string)
    field :date_of_expiry, non_null(:string)
    field :cvv, non_null(:string)
  end

  input_object :hyper_wallet_bank_card_update_type do
    field :card_number, :string
    field :date_of_expiry, :string
    field :cvv, :string
  end

  input_object :hyper_wallet_paypal_account_input_type do
    field :email, non_null(:string)
  end

  input_object :hyper_wallet_paypal_account_update_type do
    field :email, :string
  end

  input_object :hyper_wallet_venmo_account_input_type do
    # mobile number associated with venmo account
    field :account_id, non_null(:string)
  end

  input_object :hyper_wallet_venmo_account_update_type do
    # mobile number associated with venmo account
    field :account_id, :string
  end

  input_object :hyper_wallet_transaction_input_type do
    field :amount, non_null(:float)
    field :currency, non_null(:string)
    field :purpose, non_null(:string)
    field :branch_id, non_null(:integer)
    field :destination_token, :string
    field :expires_on, :datetime
    field :release_on, :datetime
    field :memo, :string
    field :notes, :string
    #    field :program_token, non_null :string
    #    field :hyper_wallet_account_user_name, non_null :string
    #    field :hyper_wallet_account_password, non_null :string
  end

  input_object :hyper_wallet_transfer_input_type do
    field :source_amount, :string
    field :client_transfer_id, non_null(:string)
    field :source_token, non_null(:string)
    field :source_currency, :string
    field :destination_token, non_null(:string)
    field :destination_amount, non_null(:string)
    field :destination_currency, non_null(:string)
    field :foreign_exchanges, list_of(:foreign_exchanges_type)
    field :memo, :string
    field :notes, :string
  end

  input_object :foreign_exchanges_type do
    field :source_amount, :string
    field :source_currency, :string
    field :destination_currency, :string
    field :destination_amount, :string
    field :rate, :string
  end

  input_object :hyper_wallet_user_get_type do
    field :user_token, non_null(:string)
  end

  input_object :hyper_wallet_transfer_method_get_type do
    field :transfer_method_id, non_null(:integer)
  end

  input_object :hyper_wallet_transfer_method_fields_get_type do
    field :user_token, non_null(:string)
    field :country, non_null(:string)
    field :currency, non_null(:string)
    field :type, non_null(:string)
    field :profile_type, non_null(:string)
  end

  input_object :hyper_wallet_currencies_get_type do
    field :country_iso2, non_null(:string)
  end

  input_object :hyper_wallet_transaction_get_type do
    field :payment_token, non_null(:string)
  end
end
