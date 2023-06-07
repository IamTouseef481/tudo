defmodule CoreWeb.GraphQL.Types.TaxType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :tax_type do
    field :id, :integer
    field :title, :string
    field :default, :boolean
    field :description, :string
    field :value, :float
    field :amount, :float
    field :is_percentage, :boolean
    field :business, :business_type, resolve: assoc(:business)
    field :tax_type, :dropdown_type, resolve: assoc(:dropdown)
  end

  # input_object :tax_input_type do
  #   field :title, non_null(:string)
  #   field :description, :string
  #   field :value, non_null(:float)
  #   field :is_percentage, non_null(:boolean)
  #   field :tax_type_id, non_null(:integer)
  #   field :business_id, non_null(:integer)
  # end

  input_object :tax_input_type do
    field :percentage, :string
    field :inclusive, :boolean
  end

  input_object :tax_update_type do
    field :id, non_null(:integer)
    field :title, :string
    field :description, :string
    field :value, :float
    field :is_percentage, :boolean
    field :tax_type_id, :integer
    field :business_id, :integer
  end

  input_object :tax_get_type do
    field :business_id, non_null(:integer)
  end

  input_object :tax_delete_type do
    field :id, non_null(:integer)
  end
end
