defmodule CoreWeb.GraphQL.Resolvers.GeoZoneResolver do
  @moduledoc false
  alias CoreWeb.Controllers.GeoZoneController

  def get_zones_by_country(_, %{input: %{country_id: _id} = input}, _) do
    case GeoZoneController.get_zones_by_country(input) do
      {:ok, zones} -> {:ok, zones}
      {:error, error} -> {:error, error}
    end
  end
end
