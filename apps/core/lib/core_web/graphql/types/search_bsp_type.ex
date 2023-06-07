defmodule CoreWeb.GraphQL.Types.SearchBSPType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :search_bsp_type do
    field :branch_id, :id
    field :name, :string
    field :description, :string
    field :expected_work_duration, :time
    field :pick_expected_work_duration, :time
    field :arrive_at, :datetime
    field :phone, :string
    field :licence_no, :string
    field :est_year, :datetime
    field :address, :json
    field :geo, :json
    field :estimated_pick_time, :json
    field :estimated_drop_time, :json
    field :pick_distance, :json
    field :drop_distance, :json
    field :fields, :json
    field :service_type_id, :string
    field :service_type_ids, list_of(:string)
    field :branch_service_id, :integer
    field :branch_service_ids, list_of(:integer)
    field :profile_pictures, list_of(:json)
    field :is_active, :boolean
    field :is_head_office, :boolean
    field :auto_assign, :boolean
    field :rating, :float
    field :cost, :float
    field :promotions, list_of(:promotion_type)
    field :rating_count, :integer
    field :custom_license_issuing_authority, :string
    # field :business_id, :id
    field :business_id, :integer
    # field :licence_issuing_authority_id, :id
    field :licence_issuing_authority_id, :integer
    # field :city_id, :id
    field :city, :integer
  end

  object :bsp_general_search_type do
    field :branches, list_of(:raw_businesses_type)
    field :total_entries, :integer
    field :total_pages, :integer
    field :page_number, :integer
  end

  object :get_availability_type do
    field :employee_id, :string
    field :availability, :json
    field :availability_schedule, :json
  end

  object :get_branch_availability_type do
    field :availability, :json
    field :availability_schedule, :json
    field :expected_work_duration, :time
    field :ewd_int, :integer
    field :branch_id, :integer
    field :name, :string
    field :phone, :string
    field :licence_no, :string
    field :est_year, :datetime
    field :address, :json
    field :geo, :json
    field :fields, :json
    field :branch_service_id, :integer
    field :profile_pictures, list_of(:json)
    field :is_active, :boolean
    field :is_head_office, :boolean
    field :auto_assign, :boolean
    field :rating, :float
    field :rating_count, :integer
    field :custom_license_issuing_authority, :string
    # field :business_id, :id
    field :business_id, :integer
    # field :licence_issuing_authority_id, :id
    field :licence_issuing_authority_id, :integer
    # field :city_id, :id
    field :city, :integer
  end

  input_object :availability_input_type do
    field :job_id, non_null(:integer)
    #    field :utc_difference, :integer
  end

  input_object :search_bsp_get_type do
    field :arrive_at, :datetime
    #    field :utc_difference, :integer
    #    field :service_id, :integer
    field :two_letter_country_code, non_null(:string)
    field :country_service_ids, list_of(:integer)
    field :country_service_id, :integer
    field :location, :geo
    field :location_src, :geo
    field :distance, :float
    field :is_flexible, :boolean
    field :rating, :float
    field :occurrence, :reoccurring_type
  end

  input_object :bsp_general_search_get_type do
    field :is_exact_search, :boolean
    field :has_contact_info, :boolean
    field :location, :geo
    field :text_search, :string
    field :distance, :float
    field :page_number, :integer
    field :page_size, :integer
    field :sort, :sort_type
    field :distance_unit, :distance_unit_type
  end

  enum :distance_unit_type do
    value(:kilometer)
    value(:miles)
  end

  input_object :branch_availability_input_type do
    field :branch_id, non_null(:integer)
    field :country_service_id, :integer
  end
end
