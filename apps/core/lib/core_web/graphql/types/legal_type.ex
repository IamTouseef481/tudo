defmodule CoreWeb.GraphQL.Types.LegalType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :platform_terms_and_conditions_type do
    field :id, :id
    field :slug, :string
    field :type, :string
    field :text, :string
    field :start_date, :datetime
    field :end_date, :datetime
    field :url, :string
    field :country, :country_type, resolve: assoc(:country)
  end

  object :licence_issuing_authorities_type do
    field :id, :id
    field :name, :string
    field :is_active, :boolean
    field :country, :country_type, resolve: assoc(:country)
  end

  input_object :platform_terms_and_conditions_input_type do
    field :slug, non_null(:string)
    field :type, non_null(:string)
    field :text, :string
    field :start_date, :datetime
    field :end_date, :datetime
    field :url, :string
    field :country_id, non_null(:integer)
  end

  input_object :platform_terms_and_conditions_update_type do
    field :id, non_null(:integer)
    field :text, :string
    field :start_date, :datetime
    field :end_date, :datetime
    field :url, :string
  end

  input_object :licence_issueing_authorities_input_type do
    field :name, non_null(:string)
    field :is_active, :boolean
    field :country_id, non_null(:integer)
  end

  input_object :licence_issueing_authorities_get_type do
    field :country_id, non_null(:integer)
  end

  input_object :platform_terms_and_conditions_accept_type do
    field :terms_accepted, non_null(:boolean)
    field :employee_id, :integer
  end
end
