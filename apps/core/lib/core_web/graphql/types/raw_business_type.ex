defmodule CoreWeb.GraphQL.Types.RawBusinessType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :raw_business_type do
    field :message, :string
  end

  object :raw_businesses_type do
    field :id, :id
    field :name, :string
    field :owner_name, :string
    field :role, :string
    field :email, :string
    field :alternate_email, :string
    field :description, :string
    field :raw_phone_details, :string
    field :website, :string
    field :phone, :string
    field :alternate_phone1, :string
    field :alternate_phone2, :string
    field :licence_no, :string
    field :terms_and_conditions_url, :string
    field :business_profile_info, :string
    field :licence_photos, list_of(:json)
    field :licence_expiry_date, :datetime
    field :personal_identification, :json
    field :profile_pictures, list_of(:json)
    field :employees_count, :integer
    field :settings, :business_settings_type
    field :est_year, :datetime
    field :address, :json
    field :zone_ids, list_of(:integer)
    field :geo, :json
    field :is_active, :boolean
    field :is_head_office, :boolean
    field :auto_assign, :boolean
    field :is_raw, :boolean
    field :is_claimed, :boolean
    field :rating, :float
    field :distance, :float
    field :rating_count, :integer
    field :custom_license_issuing_authority, :string
    field :general_liability_insured, :boolean
    field :surety_bonded, :boolean
    field :other_details, :string
    field :social_profile, :json
    #     field :business_id, :id
    field :business, :business_type, resolve: assoc(:business)
    field :business_type, :business_type_type, resolve: assoc(:business_type)
    # field :licence_issuing_authority_id, :id
    field :licence_issuing_authority, :licence_issuing_authorities_type,
      resolve: assoc(:licence_issuing_authority)

    field :employees, list_of(:employee_type), resolve: assoc(:employees)
    field :branch_services, list_of(:branch_service_type), resolve: assoc(:branch_services)
    field :active_branch_services, list_of(:branch_service_type)
    field :formatted_branch_services, :json
    # field :city_id, :id
    field :owner, :user_type
    field :city, :city_type, resolve: assoc(:city)
    field :country_id, :integer
    field :country, :country_type, resolve: assoc(:country)
    field :status, :user_status_type, resolve: assoc(:status)
  end

  input_object :raw_business_input_type do
    field :start_file_number, :integer
    field :end_file_number, :integer
  end
end
