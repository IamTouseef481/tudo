defmodule CoreWeb.Workers.RemoveLeadWorker do
  @moduledoc false
  import CoreWeb.Utils.Errors
  alias CoreWeb.GraphQL.Resolvers.LeadResolver

  def perform(id) do
    logger(__MODULE__, id, :info, __ENV__.line)

    case Core.Leads.get_lead(id) do
      %{} = lead ->
        case Core.Leads.delete_lead(lead) do
          {:ok, %{location: %{coordinates: {long, lat}}}} ->
            lead = Map.merge(lead, %{location: %{lat: lat, long: long}})
            logger(__MODULE__, lead, :info, __ENV__.line)
            LeadResolver.update_leads_prospects_dashboard_meta(lead, -1)
            {:ok, lead}

          exception ->
            logger(__MODULE__, exception, :info, __ENV__.line)
            exception
        end

      _ ->
        {:ok, ["no lead to be deleted!"]}
    end
  end
end
