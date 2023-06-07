defmodule CoreWeb.GraphQL.Types.LeadType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :lead_for_bsp_type do
    field :count, :integer
    field :data, list_of(:lead_type)
  end

  object :lead_type do
    field :id, :integer
    field :arrive_at, :datetime
    field :location, :json
    field :rating, :float
    field :is_flexible, :boolean
    field :user, :user_type, resolve: assoc(:user)
    field :country_service, :country_service_type, resolve: assoc(:country_service)
  end

  input_object :lead_get_type do
    field :location, non_null(:geo)
  end

  input_object :prospect_get_type do
    field :location, non_null(:geo)
    field :branch_service_ids, non_null(list_of(:integer))
  end
end
