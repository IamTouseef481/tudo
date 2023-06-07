defmodule CoreWeb.GraphQL.Types.BranchType do
  @moduledoc false
  use CoreWeb.GraphQL, :type
  import Ecto.Query
  alias Core.Schemas.{BusinessType, TermsAndCondition}

  object :branch_type do
    field :id, :id
    field :name, :string
    field :description, :string
    field :phone, :string
    field :licence_no, :string
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
    field :rating, :float
    field :rating_count, :integer
    field :custom_license_issuing_authority, :string
    field :general_liability_insured, :boolean
    field :surety_bonded, :boolean
    field :other_details, :string
    field :social_profile, :json
    # field :business_id, :id
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

  object :branch_list_type do
    field :total_entries, :integer
    field :total_pages, :integer
    field :page_number, :integer
    field :branches, list_of(:branch_type)
  end

  input_object :address do
    field :type, :string
    field :address, :string
    field :state, :string
    field :city, :string
    field :country, :string
    field :zip_code, :integer
    field :primary, :boolean
  end

  input_object :social_profile_input do
    field :social_fb, :string
    field :social_google, :string
    field :social_yelp, :string
    field :social_instagram, :string
  end

  input_object :geo do
    field :lat, :float
    field :long, :float
  end

  input_object :documents do
    field :issuing_authority, :integer
    field :custom_issuing_authority, :string
    field :document_number, :string
    field :document_expiry, :datetime
  end

  #  input_object :path do
  #    field :thumb, :string
  #    field :original, :string
  #  end

  input_object :icon do
    field :mime, :string
    field :name, :string
    field :path, :string
  end

  input_object :personal_identification do
    field :documents, list_of(:documents)
    field :documents_photos, list_of(:upload)
    field :rest_documents_photos, list_of(:file)
  end

  input_object :personal_identification_for_branch do
    field :documents, list_of(:documents)
    field :documents_photos, list_of(:upload)
    field :documents_photos_id1, list_of(:upload)
    field :documents_photos_id2, list_of(:upload)
    field :rest_documents_photos_id1, list_of(:file)
    field :rest_documents_photos_id2, list_of(:file)
  end

  input_object :branch_business_straight_input_type do
    #    field :business_id, non_null(:integer)
    #    field :business_type_id, non_null(:integer)
    field :description, :string
    field :services, non_null(list_of(:service_object_type))
    field :licence_no, :string
    field :licence_photos, list_of(:upload)
    field :rest_licence_photos, list_of(:file)
    field :licence_expiry_date, :datetime
    field :licence_issuing_authority_id, :integer
    field :est_year, non_null(:datetime)
    field :address, :address
    field :personal_identification, :personal_identification_for_branch
    field :custom_license_issuing_authority, :string
    field :geo, :geo
    field :general_liability_insured, :boolean
    field :surety_bonded, :boolean
    field :other_details, :string
    field :country_id, :integer
    field :social_profile, :social_profile_input
  end

  input_object :branch_straight_update_type do
    field :id, non_null(:integer)
    #    field :business_type_id, :integer
    #    field :business_id, :integer
    #    field :country_services, list_of(:integer)
    field :description, :string
    field :phone, :string
    field :is_active, :boolean
    field :auto_assign, :boolean
    field :name, :string
    field :licence_no, :string
    field :licence_photos, list_of(:upload)
    field :rest_licence_photos, list_of(:file)
    field :licence_expiry_date, :datetime
    field :licence_issuing_authority_id, :integer
    field :est_year, :datetime
    field :address, :address
    field :zone_ids, list_of(:integer)
    field :personal_identification, :personal_identification_for_branch
    field :rest_profile_pictures, list_of(:file)
    field :profile_pictures, list_of(:upload)
    field :employees_count, :integer
    field :settings, :business_settings_update_type
    field :custom_license_issuing_authority, :string
    field :geo, :geo
    field :general_liability_insured, :boolean
    field :surety_bonded, :boolean
    field :other_details, :string
    field :city_id, :integer
    field :country_id, :integer
    field :social_profile, :social_profile_input
  end

  input_object :branch_input_type do
    field :business_id, :integer
    field :business_type_id, non_null(:integer)
    field :services, list_of(:service_object_type)
    field :name, non_null(:string)
    field :description, :string
    field :phone, :string
    field :licence_no, :string
    field :licence_photos, list_of(:upload)
    field :rest_licence_photos, list_of(:file)
    field :licence_expiry_date, :datetime
    field :licence_issuing_authority_id, :integer
    field :est_year, :datetime
    field :address, :address
    field :auto_assign, :boolean
    field :zone_ids, list_of(:integer)
    field :personal_identification, :personal_identification_for_branch
    field :rest_profile_pictures, list_of(:file)
    field :profile_pictures, list_of(:upload)
    field :employees_count, :integer
    field :settings, non_null(:business_settings_input_type)
    field :custom_license_issuing_authority, :string
    field :geo, :geo
    field :general_liability_insured, :boolean
    field :surety_bonded, :boolean
    field :other_details, :string
    field :city_id, :integer
    field :country_id, :integer
    field :social_profile, :social_profile_input
  end

  input_object :branch_business_input_type do
    field :business_id, :integer
    field :business_type_id, non_null(:integer)
    field :description, :string
    field :services, list_of(:service_object_type)
    field :licence_no, :string
    field :licence_photos, list_of(:upload)
    field :rest_licence_photos, list_of(:file)
    field :licence_expiry_date, :datetime
    field :licence_issuing_authority_id, :integer
    field :est_year, :datetime
    field :address, :address
    field :personal_identification, :personal_identification_for_branch
    field :custom_license_issuing_authority, :string
    field :geo, :geo
    field :general_liability_insured, :boolean
    field :surety_bonded, :boolean
    field :other_details, :string
    field :country_id, :integer
    field :social_profile, :social_profile_input
  end

  input_object :service_object_type do
    field :country_service_id, non_null(:integer)
    field :service_type_id, non_null(:string)
  end

  input_object :branch_update_type do
    field :id, non_null(:integer)
    field :business_type_id, :integer
    field :business_id, :integer
    #    field :country_services, list_of(:integer)
    field :description, :string
    field :phone, :string
    field :is_active, :boolean
    field :auto_assign, :boolean
    field :name, :string
    field :licence_no, :string
    field :licence_photos, list_of(:upload)
    field :rest_licence_photos, list_of(:file)
    field :licence_expiry_date, :datetime
    field :licence_issuing_authority_id, :integer
    field :est_year, :datetime
    field :address, :address
    field :zone_ids, list_of(:integer)
    field :personal_identification, :personal_identification_for_branch
    field :rest_profile_pictures, list_of(:file)
    field :profile_pictures, list_of(:upload)
    field :employees_count, :integer
    field :settings, :business_settings_update_type
    field :custom_license_issuing_authority, :string
    field :geo, :geo
    field :general_liability_insured, :boolean
    field :surety_bonded, :boolean
    field :other_details, :string
    field :city_id, :integer
    field :country_id, :integer
    field :social_profile, :social_profile_input
  end

  input_object :branch_delete_type do
    field :id, non_null(:integer)
  end

  input_object :branch_listing_get_type do
    field :page_number, :integer
    field :page_size, :integer
    field :search, :string
    field :sort, :sort_type
  end

  input_object :sort_type do
    field :field, non_null(:string)
    field :ascending, non_null(:boolean)
  end

  input_object :branch_activate_type do
    field :branch_id, non_null(:integer)
    field :status_id, non_null(:string)
  end

  # DUPLICATE CODE SHOULD BE REMOVED
  def business_type_by_id(_, ids) do
    BusinessType
    |> where([m], m.id in ^ids)
    |> Core.Repo.all()
    |> Map.new(&{&1.id, &1})
  end

  def terms_and_conditions_by_id(_, ids) do
    TermsAndCondition
    |> where([m], m.id in ^ids)
    |> Core.Repo.all()
    |> Map.new(&{&1.id, &1})
  end
end
