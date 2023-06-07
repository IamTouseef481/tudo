defmodule CoreWeb.GraphQL.Resolvers.ServiceResolver do
  @moduledoc false

  alias Core.Services
  alias CoreWeb.Controllers.ServiceController
  alias CoreWeb.Helpers.CountryServiceHelper

  def service_groups(_, _, _) do
    {:ok, Services.get_service_group_by()}
  end

  def service_statuses(_, _, _) do
    {:ok, Services.list_service_statuses()}
  end

  def service_types(_, _, _) do
    {:ok, Services.list_service_types()}
  end

  def service_settings_by(_, %{input: %{country_service_id: country_service_id}}, _) do
    {:ok, Services.get_service_setting_by_country_service_id(country_service_id)}
  end

  def services(_, _, _) do
    services = Services.list_services()
    {:ok, services}
  end

  def country_services(_, _, _) do
    services = Services.list_country_services()
    {:ok, services.entries}
  end

  def get_services_by_country_id(_, %{input: input}, _) do
    with country_services <-
           CountryServiceHelper.list_country_services(input),
         service_groups <- Services.get_service_group_by(),
         country_services_grouped <-
           Enum.group_by(country_services, & &1.service.service_group_id),
         service_groups <-
           service_groups |> Enum.map(&Map.put(&1, :services, country_services_grouped[&1.id])),
         service_groups <- service_groups |> Enum.filter(&(&1.services != nil)) do
      {:ok, CountryServiceHelper.arrange(service_groups)}
    end
  end

  def get_services_by_country_id(_, _, _) do
    {:ok, %{services: []}}
  end

  def branch_services(_, _, _) do
    services = Services.list_branch_services()
    {:ok, services.entries}
  end

  def create_branch_service(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.create_branch_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_branch_service(_, %{input: %{id: branch_service_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case Services.get_branch_service(branch_service_id) do
      nil -> {:error, ["branch service doesn't exist!"]}
      %{} = branch_service -> ServiceController.update_branch_service(branch_service, input)
      _ -> {:error, ["error in fetching branch service"]}
    end
  end

  def get_branch_services_by_branch(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.get_branch_services_by_branch(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_multiple_branch_services(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.update_multiple_branch_services(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_branch_service(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.delete_branch_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_service_setting(_, %{input: input}, _) do
    case ServiceController.create_service_setting(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_service_setting(_, %{input: input}, _) do
    case ServiceController.update_service_setting(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_service_setting(_, %{input: input}, _) do
    ServiceController.delete_service_setting(input)
  end

  def create_service_group(_, %{input: input}, _) do
    case ServiceController.create_service_group(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_service_group(_, %{input: input}, _) do
    case ServiceController.update_service_group(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_service_group(_, %{input: input}, _) do
    case ServiceController.delete_service_group(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_service_group(_, %{input: input}, _) do
    case ServiceController.get_service_group(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_service_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.create_service_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_service_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.get_service_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_service_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.update_service_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_service_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.delete_service_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_service_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.create_service_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_service_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.get_service_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_service_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.update_service_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_service_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ServiceController.delete_service_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_service(_, %{input: input}, _) do
    case ServiceController.create_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_service(_, %{input: input}, _) do
    case ServiceController.update_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_service(_, %{input: input}, _) do
    case ServiceController.delete_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_country_service(_, %{input: input}, _) do
    case ServiceController.create_country_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_country_service(_, %{input: input}, _) do
    case ServiceController.update_country_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_country_service(_, %{input: input}, _) do
    case ServiceController.delete_country_service(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  #  def update_business _, %{input: input}, _ do
  #    case CoreWeb.Controllers.BusinessController.update_business(input) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #    end
  #  end
  #
  #  def delete_business _, %{input: input}, _ do
  #    case CoreWeb.Controllers.BusinessController.delete_business(input) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #    end
  #  end

  def create_services_along_with_country_services(_, params, _) do
    case ServiceController.create_services_along_with_country_services(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end
end
