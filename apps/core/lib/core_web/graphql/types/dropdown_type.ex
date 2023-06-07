defmodule CoreWeb.GraphQL.Types.DropdownType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :dropdown_type do
    field :id, :id
    field :name, :string
    field :slug, :string
    field :type, :string
    field :country, :country_type, resolve: assoc(:country)
  end

  input_object :dropdown_update_type do
    field :id, non_null(:integer)
    field :name, non_null(:string)
    field :slug, :string
    field :type, :string
  end

  input_object :dropdown_delete_type do
    field :id, non_null(:integer)
  end

  input_object :dropdown_select_type do
    field :type, non_null(:string)
    field :country_id, non_null(:integer)
  end
end
