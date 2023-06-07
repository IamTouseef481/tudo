defmodule CoreWeb.GraphQL.Types.EmployeeType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :employee_type do
    field :id, :integer
    field :allowed_annual_ansence_hrs, :integer
    field :contract_begin_date, :datetime
    field :contract_end_date, :datetime
    field :id_documents, :json
    field :pay_scale, :integer
    field :vehicle_details, :json
    field :personal_identification, :json
    field :terms_and_conditions, list_of(:integer)
    field :employee_role_in_org, :string
    field :photos, list_of(:json)
    field :approved_at, :datetime
    field :manager, :employee_type, resolve: assoc(:manager)
    field :approved_by, :employee_type, resolve: assoc(:approved_by)
    field :branch, :branch_type, resolve: assoc(:branch)
    field :user, :user_type, resolve: assoc(:user)
    field :employee_role_id, :string
    field :acl_parent_role_id, :string
    field :employee_status_id, :string
    field :employee_type_id, :string
    field :pay_rate_id, :string
    field :rating, :float
    field :shift_schedule_id, :string
    field :current_location, :json
    field :user_address, list_of(:user_address_type), resolve: assoc(:user_address)
    field :employee_setting, :employee_setting_type, resolve: assoc(:employee_setting)
    field :employee_role, :employee_role_type, resolve: assoc(:employee_role)
    field :employee_status, :employee_status_type, resolve: assoc(:employee_status)
    field :employee_type, :employee_type_type, resolve: assoc(:employee_type)
  end

  object :pay_rates_type do
    field :id, :integer
    field :name, :string
    field :details, :json
  end

  object :pay_rate_type do
    field :id, :id
    field :name, :string
    field :details, :json
  end

  object :shift_schedules_type do
    field :id, :string
    field :name, :string
    field :start_time, :time
    field :end_time, :time
  end

  object :employee_role_type do
    field :id, :string
    field :name, :string
  end

  object :employee_status_type do
    field :id, :string
    field :name, :string
  end

  object :employee_type_type do
    field :id, :string
    field :name, :string
  end

  object :employee_setting_type do
    field :id, :id
    field :employee_id, :id
    field :wallet, :boolean
    field :qualification, :boolean
    field :experience, :boolean
    field :insurance, :boolean
    field :vehicle, :boolean
    field :family, :boolean
    field :employee, :employee_type, resolve: assoc(:employee)
  end

  input_object :id_decument_type do
    field :id, :integer
    field :image, :string
  end

  input_object :vehicle_detail_type do
    field :registration_no, :string
    field :image_url, :string
  end

  input_object :invite_employee_input_type do
    field :allowed_annual_ansence_hrs, :integer
    field :contract_begin_date, :datetime
    field :contract_end_date, :datetime
    field :pay_scale, :integer
    field :vehicle_details, :vehicle_detail_type
    field :manager_id, non_null(:integer)
    field :employee_role_in_org, :string
    field :branch_id, non_null(:integer)
    field :branch_service_ids, non_null(list_of(:integer))
    field :user_email, non_null(:string)
    field :employee_role_id, non_null(:string)
    field :employee_type_id, non_null(:string)
    field :pay_rate_id, non_null(:string)
    field :shift_schedule_id, non_null(:string)
    field :current_location, :geo
    field :user_address, list_of(:user_address_input_type)
    field :wallet, :boolean
    field :qualification, :boolean
    field :experience, :boolean
    field :insurance, :boolean
    field :vehicle, :boolean
    field :family, :boolean
  end

  input_object :employee_input_type do
    field :allowed_annual_ansence_hrs, :integer
    field :contract_begin_date, :datetime
    field :contract_end_date, :datetime
    field :id_documents, :id_decument_type
    field :pay_scale, :integer
    field :vehicle_details, :vehicle_detail_type
    field :manager_id, :integer
    field :personal_identification, :personal_identification
    field :terms_and_conditions, list_of(:integer)
    field :employee_role_in_org, :string
    field :photos, list_of(:upload)
    field :rest_photos, list_of(:file)
    field :current_location, :geo
    field :branch_id, non_null(:integer)
    field :user, :user_input_type
    field :employee_role_id, non_null(:string)
    field :employee_status_id, non_null(:string)
    field :employee_type_id, non_null(:string)
    field :pay_rate_id, non_null(:string)
    field :shift_schedule_id, non_null(:string)
  end

  input_object :employee_by_user_id_type do
    field :user_id, non_null(:integer)
  end

  input_object :employee_by_branch_id_type do
    field :branch_id, non_null(:integer)
  end

  input_object :employee_service_input_type do
    field :branch_id, non_null(:integer)
    field :branch_service_id, non_null(:integer)
    field :employee_id, non_null(:integer)
    field :start_date, :datetime
    field :end_date, :datetime
  end

  input_object :employee_update_type do
    field :id, non_null(:integer)
    field :allowed_annual_ansence_hrs, :integer
    field :contract_begin_date, :datetime
    field :contract_end_date, :datetime
    field :id_documents, :id_decument_type
    field :pay_scale, :integer
    field :personal_identification, :personal_identification
    field :terms_and_conditions, list_of(:integer)
    field :employee_role_in_org, :string
    field :current_location, :geo
    field :photos, list_of(:upload)
    field :rest_photos, list_of(:file)
    field :approved_by_id, :integer
    field :vehicle_details, :vehicle_detail_type
    field :manager_id, :integer
    field :branch_id, :integer
    field :employee_role_id, :string
    field :employee_status_id, :string
    field :employee_type_id, :string
    field :pay_rate_id, :string
    field :shift_schedule_id, :string
  end

  input_object :employee_location_update_type do
    field :id, non_null(:integer)
    field :current_location, :geo
  end

  input_object :employee_delete_type do
    field :id, non_null(:integer)
  end

  input_object :employee_get_type do
    field :branch_id, non_null(:integer)
  end

  input_object :pay_rate_input_type do
    field :id, non_null(:id)
    field :name, :string
    #    field :details, :details_type
  end

  input_object :pay_rate_update_type do
    field :id, non_null(:id)
    field :name, :string
    #    field :details, :details_type
  end

  input_object :pay_rate_get_type do
    field :id, non_null(:id)
  end

  input_object :employee_role_input_type do
    field :id, non_null(:id)
    field :name, :string
  end

  input_object :employee_role_update_type do
    field :id, non_null(:id)
    field :name, :string
  end

  input_object :employee_role_get_type do
    field :id, non_null(:id)
  end

  input_object :employee_status_input_type do
    field :id, non_null(:id)
    field :name, :string
  end

  input_object :employee_status_update_type do
    field :id, non_null(:id)
    field :name, :string
  end

  input_object :employee_status_get_type do
    field :id, non_null(:id)
  end

  input_object :employee_type_input_type do
    field :id, non_null(:id)
    field :name, :string
  end

  input_object :employee_type_update_type do
    field :id, non_null(:id)
    field :name, :string
  end

  input_object :employee_type_get_type do
    field :id, non_null(:id)
  end

  input_object :shift_schedule_input_type do
    field :id, non_null(:id)
    field :name, :string
    field :start_time, :time
    field :end_time, :time
  end

  input_object :shift_schedule_update_type do
    field :id, non_null(:id)
    field :name, :string
    field :start_time, :time
    field :end_time, :time
  end

  input_object :shift_schedule_get_type do
    field :id, non_null(:id)
  end

  input_object :employee_setting_input_type do
    field :employee_id, non_null(:id)
    field :wallet, :boolean
    field :qualification, :boolean
    field :experience, :boolean
    field :insurance, :boolean
    field :vehicle, :boolean
    field :family, :boolean
  end

  input_object :employee_setting_update_type do
    field :employee_id, non_null(:id)
    field :wallet, :boolean
    field :qualification, :boolean
    field :experience, :boolean
    field :insurance, :boolean
    field :vehicle, :boolean
    field :family, :boolean
  end

  input_object :employee_setting_get_type do
    field :employee_id, :id
  end
end
