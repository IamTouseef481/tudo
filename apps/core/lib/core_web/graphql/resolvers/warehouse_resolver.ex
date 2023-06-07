defmodule CoreWeb.GraphQL.Resolvers.WarehouseResolver do
  use CoreWeb, :core_resolver
  alias Core.Warehouses
  alias CoreWeb.Utils.CommonFunctions

  def create_warehouse(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    case Warehouses.create_warehouse(
           Map.merge(input, %{location: CommonFunctions.location_struct(input[:location])})
         ) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end
end
