defmodule CoreWeb.GraphQL.Types.SettingType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :setting_type do
    field :id, :integer
    field :title, :string
    field :slug, :string
    field :type, :string
    field :branch, :branch_type, resolve: assoc(:branch)
    field :fields, :json
  end

  object :bsp_setting_type do
    field :id, :integer
    field :title, :string
    field :slug, :string
    field :type, :string
    field :branch, :branch_type, resolve: assoc(:branch)
    field :fields, :json
  end

  object :cmr_settings_type do
    field :id, non_null(:integer)
    field :title, :string
    field :type, :string
    field :slug, :string
    field :fields, list_of(:json)
    field :employee, :employee_type, resolve: assoc(:employee)
    #    field :branch, :branch_type, resolve: assoc(:branch)
    field :user, :user_type, resolve: assoc(:user)
  end

  object :tudo_setting_type do
    field :id, :integer
    field :title, :string
    field :slug, non_null(:string)
    field :value, non_null(:float)
    field :unit, :string
    field :is_active, :boolean
    field :country_id, :country_type, resolve: assoc(:country)
  end

  input_object :setting_get_type do
    field :type, :string
    field :branch_id, :integer
  end

  input_object :bsp_setting_get_by_type do
    field :slug, :string
    field :branch_id, non_null(:integer)
  end

  input_object :bsp_setting_delete_type do
    field :setting_id, non_null(:integer)
  end

  input_object :setting_input_type do
    field :title, :string
    field :slug, :string
    field :type, :string
    field :branch_id, non_null(:integer)
    field :fields, :availability
  end

  input_object :bsp_setting_input_type do
    field :title, :string
    field :slug, non_null(:string)
    field :type, :string
    field :branch_id, non_null(:integer)
    field :fields, list_of(:string)
  end

  input_object :bsp_setting_update_type do
    field :setting_id, non_null(:integer)
    field :title, :string
    field :slug, :string
    field :type, :string
    field :branch_id, :integer
    field :fields, list_of(:string)
  end

  input_object :setting_update_type do
    field :setting_id, non_null(:integer)
    field :title, :string
    field :slug, :string
    field :type, :string
    field :branch_id, :integer
    field :fields, :availability
  end

  input_object :business_setting_update_type do
    field :title, :string
    field :slug, non_null(:string)
    field :type, :string
    field :branch_id, non_null(:integer)
    field :fields, :string
  end

  input_object :availability do
    field :default, :day_map
    field :custom, :day_map
  end

  input_object :day_map do
    field :monday, :shift
    field :tuesday, :shift
    field :wednesday, :shift
    field :thursday, :shift
    field :friday, :shift
    field :saturday, :shift
    field :sunday, :shift
  end

  input_object :shift do
    field :a, :shift_and_breaks
    field :b, :shift_and_breaks
    field :c, :shift_and_breaks
    field :d, :shift_and_breaks
  end

  input_object :shift_and_breaks do
    field :shift, :to_from
    field :breaks, list_of(:to_from)
  end

  input_object :to_from do
    field :from, non_null(:time)
    field :to, non_null(:time)
    field :name, non_null(:string)
    field :description, :string
  end

  input_object :cmr_settings_input_type do
    field :employee_id, :integer
    field :title, :string
    field :type, :string
    field :slug, :string
    field :fields, list_of(:string)
  end

  input_object :employee_details_input_type do
    field :employee_id, non_null(:integer)
    field :vehicles, list_of(:string)
    field :insurance, list_of(:string)
    field :qualification, list_of(:string)
    field :work_experience, list_of(:string)
    field :personal_identification, list_of(:string)
  end

  input_object :cmr_settings_update_type do
    field :id, non_null(:integer)
    field :employee_id, :integer
    field :title, :string
    field :type, :string
    field :slug, :string
    field :fields, list_of(:string)
  end

  input_object :tudo_setting_input_type do
    field :title, :string
    field :slug, non_null(:string)
    field :value, non_null(:float)
    field :unit, :string
    field :is_active, :boolean
    field :country_id, :integer
  end

  input_object :tudo_setting_update_type do
    field :id, non_null(:integer)
    field :title, :string
    #    field :slug, :string
    field :value, :float
    field :unit, :string
    field :is_active, :boolean
    field :country_id, :integer
  end

  input_object :cmr_settings_get_by_type do
    field :user_id, non_null(:integer)
  end

  input_object :employee_details_get_by_type do
    field :employee_id, non_null(:integer)
  end

  input_object :cmr_settings_delete_type do
    field :id, non_null(:integer)
  end

  input_object :tudo_setting_delete_type do
    field :id, non_null(:integer)
  end
end
