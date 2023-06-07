defmodule CoreWeb.GraphQL.Types.TudoChargesType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :tudo_charges_type do
    field :id, :integer
    field :name, :string
    field :slug, :string
    field :application_id, :string
    field :branch_id, :integer
    field :country_id, :integer
    field :is_percentage, :boolean
    field :value, :float
  end

  input_object :tudo_charges_input_type do
    field :name, non_null(:string)
    field :slug, non_null(:string)
    field :application_id, non_null(:string)
    field :branch_id, :integer
    field :country_id, :integer
    field :is_percentage, :boolean
    field :value, non_null(:float)
  end

  input_object :tudo_charges_update_type do
    field :id, non_null(:integer)
    field :name, :string
    field :slug, :string
    field :application_id, :string
    field :branch_id, :integer
    field :country_id, :integer
    field :is_percentage, :boolean
    field :value, :float
  end

  input_object :tudo_charges_delete_type do
    field :id, non_null(:integer)
  end
end
