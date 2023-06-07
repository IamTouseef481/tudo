defmodule CoreWeb.GraphQL.Types.MetaType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :meta_bsp_type do
    field :id, :id
    field :type, :string
    field :terms_accepted, :boolean
    field :statistics, :json
    field :employee, :employee_type, resolve: assoc(:employee)
    field :user, :user_type, resolve: assoc(:user)
    field :branch, :branch_type, resolve: assoc(:branch)
  end

  object :meta_cmr_type do
    field :id, :id
    field :type, :string
    field :terms_accepted, :boolean
    field :statistics, :json
    field :user, :user_type, resolve: assoc(:user)
  end

  input_object :bsp_meta_get_type do
    field :employee_id, non_null(:id)
    field :type, non_null(:string)
  end

  input_object :cmr_meta_get_type do
    field :type, non_null(:string)
  end

  input_object :meta_delete_type do
    field :id, non_null(:id)
  end

  input_object :meta_bsp_join_type do
    field :employee_id, non_null(:integer)
  end
end
