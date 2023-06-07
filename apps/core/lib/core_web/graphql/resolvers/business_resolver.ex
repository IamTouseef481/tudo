defmodule CoreWeb.GraphQL.Resolvers.BusinessResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias Core.{Accounts, BSP, Services}
  alias CoreWeb.GraphQL.Resolvers.UserResolver

  def list_businesses(_, _, _) do
    businesses = BSP.list_businesses()

    businesses =
      Enum.map(businesses, fn business ->
        setting = keys_to_atoms(business.settings)
        %{business | settings: setting}
      end)

    {:ok, businesses}
  end

  def get_business(_, %{input: %{id: id}}, _) do
    businesses = BSP.get_business_by_user_id(id)

    businesses =
      Enum.map(businesses, fn business ->
        branches = Enum.map(business.branches, &attach_grouped_branch_services_to_branch(&1))
        branches = Enum.map(branches, &add_issuing_authority_name(&1))
        branches = Enum.map(branches, &preload_active_branch_services_to_branch(&1))
        business = %{business | branches: branches}
        setting = keys_to_atoms(business.settings)
        %{business | settings: setting}
      end)

    {:ok, businesses}
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to list businesses"], __ENV__.line)
  end

  def preload_active_branch_services_to_branch(branch) do
    Map.merge(branch, %{active_branch_services: Services.get_branch_services_by_branch(branch.id)})
  end

  def attach_grouped_branch_services_to_branch(branch) do
    branch_services =
      Services.get_active_services_by_branch(branch.id)
      |> make_services_grouped()

    Map.merge(branch, %{formatted_branch_services: branch_services})
  end

  def make_services_grouped(services) do
    services =
      Enum.reduce(services, %{home_service: [], walk_in: [], on_demand: []}, fn service, acc ->
        data = [
          %{
            id: service.id,
            name: service.name,
            service_group_id: Map.get(service, :service_group_id),
            branch_service_id: Map.get(service, :branch_service_id),
            service_type_id: Map.get(service, :service_type_id),
            country_service_id: Map.get(service, :country_service_id)
          }
        ]

        case service.service_type_id do
          "walk_in" -> Map.merge(acc, %{walk_in: acc.walk_in ++ data})
          "on_demand" -> Map.merge(acc, %{on_demand: acc.on_demand ++ data})
          "home_service" -> Map.merge(acc, %{home_service: acc.home_service ++ data})
          _ -> acc
        end
      end)

    %{walk_in: walk_in, on_demand: on_demand, home_service: home_service} = services
    walk_in = Services.make_services_grouped(walk_in)
    on_demand = Services.make_services_grouped(on_demand)
    home_service = Services.make_services_grouped(home_service)
    %{walk_in: walk_in, on_demand: on_demand, home_service: home_service}
  end

  def add_issuing_authority_name(branch) do
    if is_map(branch.personal_identification) and
         Map.has_key?(branch.personal_identification, "documents") and
         is_list(branch.personal_identification["documents"]) do
      documents =
        Enum.map(branch.personal_identification["documents"], fn document ->
          if Map.has_key?(document, "issuing_authority") and
               is_integer(document["issuing_authority"]) do
            case Core.BSP.get_dropdown(document["issuing_authority"]) do
              %{name: name} -> Map.merge(document, %{"issuing_authority_name" => name})
              _ -> document
            end
          else
            document
          end
        end)

      ps = Map.merge(branch.personal_identification, %{"documents" => documents})
      Map.merge(branch, %{personal_identification: ps})
    else
      branch
    end
  end

  #  def create_business _, %{input: input}, %{context: %{current_user: current_user}} do
  #    input = Map.merge(input, %{user_id: current_user.id, acl_role_id: current_user.acl_role_id})
  #    case CoreWeb.Controllers.BusinessController.create_business(input) do
  #      {:ok, data} ->
  #        #        Absinthe.Subscription.publish(CoreWeb.Endpoint, user, create_user: true)
  #        {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #    end
  #  end

  def create_business(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case check_admin_or_current_user(input, current_user) do
      {:error, error} ->
        {:error, error}

      user_info ->
        case CoreWeb.Controllers.BusinessController.create_business(Map.merge(input, user_info)) do
          {:ok, data} -> {:ok, data}
          {:error, changeset} -> {:error, changeset}
          _ -> {:error, ["unable to create business!"]}
        end
    end
  end

  def update_business(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{current_user: current_user})

    case CoreWeb.Controllers.BusinessController.update_business(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unable to update business!"]}
    end
  end

  def make_business_active(_, %{input: %{business_id: bus_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    if "web" in current_user.acl_role_id do
      case BSP.get_business(bus_id) do
        nil ->
          {:error, ["business doesn't exist"]}

        %{} = bus ->
          case BSP.update_business(bus, input) do
            {:ok, data} -> {:ok, %{data | settings: keys_to_atoms(data.settings)}}
            {:error, changeset} -> {:error, changeset}
            _ -> {:error, ["unable to update business!"]}
          end
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unexpected error occurred, try again!"], __ENV__.line)
  end

  def delete_business(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user: current_user})

    case CoreWeb.Controllers.BusinessController.delete_business(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_straight_business(_, %{input: %{user: user} = input}, _) do
    case UserResolver.create_straight_user(
           Map.merge(user, %{
             country_id: get_in(input, [:branch, :country_id]),
             mobile: input[:phone]
           })
         ) do
      #      {:ok, _last, %{email_taken: %{status_id: "registration_pending"}, user: user}} -> {:ok, user}
      {:ok, _last, %{user: %{id: user_id, country_id: country_id, email: email}}} ->
        input =
          Map.merge(input, %{
            user_id: user_id,
            country_id: country_id,
            settings: %{
              providesOnDemand: true,
              providesWalkin: true,
              providesHomeService: true
            }
          })

        case CoreWeb.Controllers.BusinessController.create_business(input) do
          {:ok, data} ->
            send_email_with_attachment(email, data)
            {:ok, data}

          {:error, changeset} ->
            {:error, changeset}

          _ ->
            {:error, ["unable to create business!"]}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  def send_email_with_attachment(email, data) do
    Task.start(fn ->
      CoreWeb.PDF.MakePDF.send_email_with_attachment(
        "BSP_Availability_QR_Code_Email",
        %{
          "email" => email,
          "bsp_branch_profile_name" => data.branch_name,
          "branch_id" => data.branch_id
        },
        data
      )
    end)
  end

  defp check_admin_or_current_user(input, %{
         country_id: country_id,
         id: current_user_id,
         acl_role_id: roles
       }) do
    if Map.has_key?(input, :user_id) do
      if "web" in roles do
        case Accounts.get_user!(input.user_id) do
          nil -> {:error, ["user does not exist!"]}
          %{country_id: country_id} -> %{user_id: input.user_id, country_id: country_id}
        end
      else
        {:error, ["You are not allowed to perform this action!"]}
      end
    else
      country_id =
        case input do
          %{branch: %{country_id: country_id}} -> country_id
          _ -> country_id
        end

      %{user_id: current_user_id, country_id: country_id}
    end
  end
end
