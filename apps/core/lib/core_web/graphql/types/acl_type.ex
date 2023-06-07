defmodule CoreWeb.GraphQL.Types.AclType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :acl_role_type do
    field :id, :string
    field :parent, :string
  end

  #  input_object :id_decument_type do
  #    field :id, :integer
  #    field :image, :string
  #  end
  #  input_object :vehicle_detail_type do
  #    field :registration_no, :string
  #    field :image_url, :string
  #  end
  #  input_object :employee_input_type do
  #    field :allowed_annual_ansence_hrs, :integer
  #    field :contract_begin_date, :datetime
  #    field :contract_end_date, :datetime
  #    field :id_documents, :id_decument_type
  #    field :pay_scale, :integer
  #    field :vehicle_details, :vehicle_detail_type
  #    field :manager_id, :integer
  #    field :branch_id, non_null :integer
  #    field :user_id, non_null :integer
  #    field :employee_role_id, non_null :string
  #    field :employee_status_id, non_null :string
  #    field :employee_type_id, non_null :string
  #    field :pay_rate_id, non_null :string
  #    field :shift_schedule_id, non_null :string
  #  end

  #  input_object :employee_delete_type do
  #    field :id, non_null :integer
  #  end
  #  input_object :employee_get_type do
  #    field :branch_id, non_null :integer
  #  end
end
