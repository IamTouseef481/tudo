defmodule CoreWeb.GraphQL.Types.ServiceType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :country_service_groups_type do
    field :data, :json
  end

  object :service_group_type do
    field :id, :id
    field :name, :string
    field :is_active, :boolean
  end

  object :service_status_type do
    field :id, :id
    field :description, :string
  end

  object :service_type_type do
    field :id, :id
    field :description, :string
  end

  object :service_setting_type do
    field :id, :id
    field :fields, :json
    field :country_service, :country_service_type, resolve: assoc(:country_service)
  end

  object :service_type do
    field :id, :id
    field :name, :string
    field :service_group, :service_group_type, resolve: assoc(:service_group)
    field :service_type, :service_type_type, resolve: assoc(:service_type)
    field :service_status, :service_status_type, resolve: assoc(:service_status)
    field :service_type_id, :string
  end

  object :country_service_type do
    field :id, :id
    field :is_active, :boolean
    field :service, :service_type, resolve: assoc(:service)
    field :country, :country_type, resolve: assoc(:country)
  end

  object :branch_service_type do
    field :id, :integer
    field :is_active, :boolean
    field :auto_assign, :boolean
    field :country_service, :country_service_type, resolve: assoc(:country_service)
    field :branch, :branch_type, resolve: assoc(:branch)
    field :service_type, :service_type_type, resolve: assoc(:service_type)
  end

  object :employee_service_type do
    field :id, :integer
    field :branch, :branch_type, resolve: assoc(:branch)
    field :employee, :employee_type, resolve: assoc(:employee)
    field :start_date, :datetime
    field :end_date, :datetime
  end

  object :grouped_service_type do
    field :grouped_services, list_of(:service_data)
    field :service_group_name, :string
  end

  object :service_data do
    field :id, :id
    field :name, :string
    field :service_type_id, :string
    field :country_service_id, :integer
    field :branch_service_id, :integer
  end

  input_object :employee_service_update_type do
    field :id, :integer
    field :start_date, :datetime
    field :end_date, :datetime
    field :branch_service_id, non_null(:integer)
    field :employee_id, non_null(:integer)
  end

  input_object :employee_service_delete_type do
    field :id, non_null(:integer)
  end

  input_object :branch_service_input_type do
    field :is_active, :boolean
    field :auto_assign, :boolean
    field :country_service_id, non_null(:integer)
    field :branch_id, non_null(:integer)
    field :service_type_id, non_null(:string)
  end

  input_object :branch_service_update_type do
    field :id, non_null(:id)
    field :is_active, :boolean
    field :auto_assign, :boolean
    #    field :country_service_id, :integer
    #    field :branch_id, :integer
    #    field :service_type_id, :string
  end

  input_object :branch_services_update_type do
    field :branch_id, non_null(:integer)
    field :service_type_id, non_null(:string)
    field :is_active, non_null(:boolean)
  end

  input_object :branch_service_delete_type do
    field :id, non_null(:integer)
  end

  input_object :branch_service_get_type do
    field :branch_id, non_null(:integer)
  end

  input_object :country_service_group_type do
    field :country_id, non_null(:integer)
    field :on_demand, non_null(:boolean)
    field :walk_in, non_null(:boolean)
    field :home_service, non_null(:boolean)
  end

  input_object :create_services_along_with_country_services_type do
    field :service_name, non_null(:string)
    field :service_group_id, non_null(:integer)
    field :country_ids, list_of(non_null(:integer))
    field :service_type_id, non_null(:string)
    field :service_setting_field, non_null(:service_setting_feild_input_type)
  end

  input_object :service_setting_feild_input_type do
    field :distance_limit, non_null(:integer)
    field :is_flexible, non_null(:boolean)
  end

  input_object :service_setting_input_type do
    field :country_service_id, non_null(:integer)
    field :fields, :string
  end

  input_object :get_service_setting_input_type do
    field :country_service_id, non_null(:integer)
  end

  input_object :service_setting_update_type do
    field :id, non_null(:integer)
    field :country_service_id, :integer
    field :fields, :string
  end

  input_object :service_setting_delete_type do
    field :id, non_null(:integer)
  end

  input_object :service_group_input_type do
    field :name, :string
    field :is_active, :boolean
  end

  input_object :service_group_update_type do
    field :id, :integer
    field :name, :string
    field :is_active, :boolean
  end

  input_object :service_group_delete_type do
    field :id, non_null(:integer)
  end

  input_object :service_input_type do
    field :name, non_null(:string)
    field :service_group_id, non_null(:integer)
    field :service_type_id, non_null(:string)
    field :service_status_id, non_null(:string)
  end

  input_object :service_update_type do
    field :id, non_null(:integer)
    field :name, :string
    field :service_group_id, :integer
    field :service_status_id, :string
  end

  input_object :service_delete_type do
    field :id, non_null(:integer)
  end

  input_object :country_service_input_type do
    field :is_active, :boolean
    field :country_id, non_null(:integer)
    field :service_id, non_null(:integer)
  end

  input_object :country_service_update_type do
    field :id, non_null(:integer)
    field :is_active, :boolean
    field :country_id, :integer
    field :service_id, :integer
  end

  input_object :country_service_delete_type do
    field :id, non_null(:integer)
  end

  input_object :service_status_input_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :service_status_update_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :service_status_get_type do
    field :id, non_null(:id)
  end

  input_object :service_type_input_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :service_type_update_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :service_type_get_type do
    field :id, non_null(:id)
  end
end
