defmodule CoreWeb.GraphQL.Resolvers.LeadResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias Core.{BSP, Employees, Leads, MetaData, Services}

  def create_lead(%{location: _, service_ids: service_ids} = input) do
    input = Map.drop(input, [:service_ids])

    lead_ids =
      Enum.reduce(service_ids, [], fn id, acc ->
        case create_new_lead(Map.merge(input, %{service_id: id})) do
          {:ok, %{id: lead_id}} -> [lead_id | acc]
          {:error, _error} -> acc
        end
      end)

    if lead_ids == [],
      do: {:error, "Could not create any lead"},
      else: {:ok, lead_ids}
  end

  def create_lead(%{location: _location} = input) do
    # location = if is_struct(location), do: location, else: location_struct(location)
    # updated_input = Map.merge(input, %{location: location})
    create_new_lead(input)
  end

  defp create_new_lead(%{location: location} = input) do
    location = if is_struct(location), do: location, else: location_struct(location)
    input = Map.merge(input, %{location: location})

    case Leads.create_lead(input) do
      {:ok, %{id: lead_id} = lead} ->
        update_leads_prospects_dashboard_meta(input, 1)

        Exq.enqueue_at(
          Exq,
          "default",
          #          Timex.shift(DateTime.utc_now(), seconds: 10),
          Timex.shift(DateTime.utc_now(), months: 6),
          "CoreWeb.Workers.RemoveLeadWorker",
          [lead_id]
        )

        {:ok, lead}

      _ ->
        {:error, ["error while creating lead"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["lead not created"], __ENV__.line)
  end

  def update_leads_prospects_dashboard_meta(input, counter) do
    branches = BSP.get_branches_for_leads(input)
    update_employee_meta_on_leads_prospects(branches, "leads", counter)
    branches = BSP.get_branches_for_prospects(input)
    update_employee_meta_on_leads_prospects(branches, "prospects", counter)
  end

  def update_employee_meta_on_leads_prospects(branches, tile, counter) do
    Enum.reduce(branches, [], fn %{branch_id: branch_id}, acc ->
      case Employees.get_owner_by_branch_id(branch_id) do
        %{id: owner_employee_id} ->
          update_leads_prospects_counter(owner_employee_id, branch_id, tile, counter)

        _ ->
          acc
      end
    end)
  end

  def update_leads_prospects_counter(employee_id, branch_id, tile, counter) do
    case MetaData.get_dashboard_meta_by_employee_id(employee_id, branch_id, "dashboard") do
      [] ->
        {:ok, ["valid"]}

      [data] ->
        {_, %{statistics: updated_statistics}} =
          get_and_update_in(data.statistics["#{tile}"]["count"], &{&1, &1 + counter})

        case MetaData.update_meta_bsp(data, %{statistics: updated_statistics}) do
          {:ok, data} ->
            #            Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_bsp_socket: "*")
            #            meta_data  = Map.drop(data, [:__meta__, :__struct__, :user, :branch, :employee])
            #            CoreWeb.Endpoint.broadcast("meta_bsp:employee_id:#{employee_id}", "meta_bsp", %{statistics: updated_statistics})
            {:ok, data}

          _ ->
            {:ok, ["valid"]}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["valid"], __ENV__.line)
  end

  def get_leads_for_bsp(_, %{input: %{location: %{lat: lat, long: long}}}, _) do
    {:ok, get_leads_by({long, lat})}
  end

  def get_prospects_for_bsp(
        _,
        %{input: %{location: %{lat: lat, long: long}, branch_service_ids: bs_ids}},
        _
      ) do
    {:ok, get_prospects_by({long, lat}, bs_ids)}
  end

  def get_leads_by(coordinates) do
    leads = Leads.list_leads()
    # take it from branch settings
    branch_radius = 30

    #        branch_location = Geo.WKB.encode!(branch_location)
    #        leads = Leads.get_leads_by_location(branch_location, %{"distance_limit" => branch_radius})

    leads =
      Enum.reduce(leads, [], fn %{location: %{coordinates: lead_location}} = lead, acc ->
        dis = calculate_distance_between_two_coordinates(coordinates, lead_location)
        if dis <= branch_radius, do: [lead | acc], else: acc
      end)

    %{count: Enum.count(leads), data: Enum.map(leads, &location(&1))}
  end

  def get_prospects_by(coordinates, branch_service_ids) do
    country_service_ids =
      Enum.reduce(branch_service_ids, [], fn bs_id, acc ->
        case Services.get_branch_service(bs_id) do
          %{country_service_id: cs_id} -> [cs_id | acc]
          _ -> acc
        end
      end)

    prospects = Leads.get_leads_by_country_services(country_service_ids)
    # take it from branch settings
    branch_radius = 30

    #        branch_location = Geo.WKB.encode!(branch_location)
    #        leads = Leads.get_leads_by_location(branch_location, %{"distance_limit" => branch_radius})

    prospects =
      Enum.reduce(prospects, [], fn %{location: %{coordinates: lead_location}} = lead, acc ->
        dis = calculate_distance_between_two_coordinates(coordinates, lead_location)
        if dis <= branch_radius, do: [lead | acc], else: acc
      end)

    %{count: Enum.count(prospects), data: Enum.map(prospects, &location(&1))}
  end
end
