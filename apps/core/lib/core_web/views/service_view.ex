defmodule CoreWeb.Views.ServiceView do
  @moduledoc false
  use CoreWeb, :view
  alias Core.Schemas.Service

  def render("index.json", %{service_groups: service_groups}) do
    %{status: "ok", data: render_many(service_groups, __MODULE__, "service_group.json")}
  end

  def render("service_group.json", %{service_group: %{services: services} = service_group}) do
    %{
      id: service_group.id,
      name: service_group.name,
      services:
        if(services == nil,
          do: [],
          else: render_many(services, __MODULE__, "country_service.json")
        ),
      is_active: service_group.is_active
    }
  end

  def render("country_service.json", %{
        country_service: %{service: %Service{} = service} = country_service
      }) do
    %{
      render_one(service, __MODULE__, "service.json")
      | id: country_service.id
    }
  end

  def render("service.json", %{service: service}) do
    %{
      id: service.id,
      service_group_id: service.service_group_id,
      name: service.name
    }
  end

  def render("service_group.json", %{service_group: service_group}) do
    %{id: service_group.id, name: service_group.name, is_active: service_group.is_active}
  end
end
