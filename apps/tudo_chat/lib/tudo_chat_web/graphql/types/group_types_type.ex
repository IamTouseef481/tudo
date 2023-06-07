defmodule TudoChatWeb.GraphQL.Types.GroupTypesType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :group_types_type do
    field :id, :id
    field :description, :string
  end

  input_object :group_types_input_type do
    field :id, non_null(:string)
    field :description, :string
  end

  input_object :group_types_get_type do
    field :id, non_null(:string)
  end
end
