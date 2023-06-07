defmodule CoreWeb.GraphQL.Types.BusinessTypeType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :business_type_type do
    field :id, non_null(:id)
    field :name, :string
  end

  input_object :business_type_input_type do
    field :name, non_null(:string)
  end

  input_object :business_type_update_type do
    field :id, non_null(:id)
    field :name, non_null(:string)
  end

  input_object :business_type_get_type do
    field :id, non_null(:id)
  end
end
