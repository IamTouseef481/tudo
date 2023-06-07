defmodule CoreWeb.GraphQL.Types.WarehouseType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :warehouse_type do
    field :id, :id
    field :address, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :zip_code, :string
    field :phone, :string
    field :location, :json
    field :employee, :employee_type, resolve: assoc(:employee)
  end

  input_object :create_warehouse_input_type do
    field :address, non_null(:string)
    field :phone, non_null(:string)
    field :employee_id, non_null(:integer)
    field :city, :string
    field :country, :string
    field :state, :string
    field :zip_code, :string
    field :location, :geo
    #    field :employee_id, :integer
  end
end
