defmodule CoreWeb.Helpers.CountryServiceHelper do
  #   Core.Services.CountryService.Sages
  @moduledoc false

  import Ecto.Query

  alias Core.Repo
  alias Core.Schemas.{CountryService, Service}

  require IEx

  def list_country_services do
    query = list_countries_query()

    query
    |> preload(:service)
    |> Repo.all()
    |> Enum.filter(& &1.is_active)
    |> Enum.sort_by(& &1.service.name)
  end

  def list_country_services(%{
        country_id: country_id,
        home_service: true,
        on_demand: true,
        walk_in: true
      }),
      do: list_country_services_by_type(country_id, ["on_demand", "home_service", "walk_in"])

  def list_country_services(%{country_id: country_id, home_service: true, on_demand: true}),
    do: list_country_services_by_type(country_id, ["on_demand", "home_service"])

  def list_country_services(%{country_id: country_id, home_service: true, walk_in: true}),
    do: list_country_services_by_type(country_id, ["walk_in", "home_service"])

  def list_country_services(%{country_id: country_id, on_demand: true, walk_in: true}),
    do: list_country_services_by_type(country_id, ["on_demand", "walk_in"])

  def list_country_services(%{country_id: country_id, home_service: true}),
    do: list_country_services_by_type(country_id, ["home_service"])

  def list_country_services(%{country_id: country_id, on_demand: true}),
    do: list_country_services_by_type(country_id, ["on_demand"])

  def list_country_services(%{country_id: country_id, walk_in: true}),
    do: list_country_services_by_type(country_id, ["walk_in"])

  def list_country_services(%{country_id: country_id}),
    do: list_country_services_by_type(country_id, ["on_demand", "home_service", "walk_in"])

  def list_country_services(_params), do: []

  def list_country_services_by_type(country, types) do
    query =
      from(lcs in CountryService, join: s in Service, on: lcs.service_id == s.id)
      |> where([_, s], s.service_type_id in ^types)
      |> where([lcs, _], lcs.country_id in [1, ^country])
      |> where([lcs, _], lcs.is_active == true)
      |> distinct([lcs, _], lcs.service_id)
      |> order_by([_, s], asc: s.name)

    #    pagination_params = CoreWeb.Utils.Paginator.make_pagination_params()
    query
    |> preload(:service)
    |> Repo.all()

    #    |> Scrivener.Paginater.paginate(pagination_params)
  end

  def list_countries_query do
    from(lcs in CountryService)
    |> distinct([lcs], [lcs.service_id])
  end

  def arrange(service_groups) do
    service_groups |> Enum.map(&make_groups(&1))
  end

  def make_groups(%{services: services} = service_group) do
    services =
      if services == nil do
        []
      else
        #        Enum.map(services, &make_service &1)
        Enum.reduce(services, [], fn %{service: service} = c_s, acc ->
          if service.service_status_id == "active", do: acc ++ [make_service(c_s)], else: acc
        end)
      end

    %{
      id: service_group.id,
      name: service_group.name,
      services: services,
      is_active: service_group.is_active
    }
  end

  def make_service(%{service: %Service{} = service, id: country_service_id} = _country_service) do
    %{
      id: service.id,
      country_service_id: country_service_id,
      service_group_id: service.service_group_id,
      service_type_id: service.service_type_id,
      name: service.name
      #      service_status_id: service.service_status_id
    }
  end
end
