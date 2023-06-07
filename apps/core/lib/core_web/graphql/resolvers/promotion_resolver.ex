defmodule CoreWeb.GraphQL.Resolvers.PromotionResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver

  alias Core.{BSP, Promotions, Services, Accounts}
  alias CoreWeb.Controllers.PromotionController
  alias CoreWeb.GraphQL.Resolvers.BusinessResolver

  @common_error ["Something went wrong, can't create Promotion"]

  def promotion_statuses(_, _, _) do
    {:ok, Promotions.list_promotion_statuses()}
  end

  def get_deals_by(_, %{input: %{user_id: user_id} = input}, _) do
    %{country_id: country_id} = Accounts.get_user!(user_id)

    case PromotionController.get_deals_by(input) do
      {:ok, data} ->
        data =
          case input do
            %{service_types: types} ->
              attach_services_to_promotions(data, types, country_id)

            _ ->
              attach_services_to_promotions(data, country_id)
          end

        {:ok, sort_deals(data, input)}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def get_deals_by(_, %{input: input}, _) do
    case PromotionController.get_deals_by(input) do
      {:ok, data} ->
        data =
          case input do
            %{service_types: types} ->
              attach_services_to_promotions(%{promotions: data, types: types})

            _ ->
              attach_services_to_promotion(data)
          end

        {:ok, sort_deals(data, input)}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def sort_deals(deals, params) do
    case params do
      %{sort: %{field: "value", ascending: ascending}} ->
        order = if ascending, do: :asc, else: :desc
        Enum.sort_by(deals, & &1.value, order)

      %{sort: %{field: "expires_in", ascending: ascending}} ->
        order = if ascending, do: :asc, else: :desc

        deals =
          Enum.map(deals, fn %{begin_date: begin, end_date: expire} = deal ->
            Map.merge(deal, %{expires_in: Timex.diff(expire, begin, :second)})
          end)

        Enum.sort_by(deals, & &1.expires_in, order)

      %{sort: %{field: "branch_rating", ascending: ascending}} ->
        order = if ascending, do: :asc, else: :desc

        add_branch_rating(deals)
        |> Enum.sort_by(& &1.branch_rating, order)

      %{sort: %{field: "service_name", ascending: ascending}} ->
        order = if ascending, do: :asc, else: :desc
        sort_services_based_on_name(deals, order)

      _ ->
        Enum.sort_by(deals, & &1.value, :desc)
    end
  end

  def sort_services_based_on_name(deals, order) do
    Enum.map(deals, fn
      %{services: type_services} = deal ->
        services =
          Enum.reduce(type_services, type_services, fn {type, services}, acc ->
            typed_services =
              Enum.map(services, fn %{grouped_services: grouped_services} = service ->
                grouped_services = Enum.sort_by(grouped_services, & &1.name, order)
                Map.merge(service, %{grouped_services: grouped_services})
              end)

            Map.put(acc, type, typed_services)
          end)

        Map.merge(deal, %{services: services})

      deal ->
        deal
    end)
  end

  def add_branch_rating(deals) do
    Enum.map(deals, fn %{branch_id: branch_id} = deal ->
      case BSP.get_branch!(branch_id) do
        %{rating: rating} -> Map.merge(deal, %{branch_rating: rating})
        _ -> Map.merge(deal, %{branch_rating: 0})
      end
    end)
  end

  def get_available_promotions(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PromotionController.get_available_promotions(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_promotion_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PromotionController.create_promotion_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_promotion_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PromotionController.get_promotion_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_promotion_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PromotionController.update_promotion_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_promotion_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PromotionController.delete_promotion_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_promotion(_, %{input: input}, _) do
    input = if Map.get(input, :radius), do: input, else: Map.merge(input, %{radius: 50.0})

    case CoreWeb.Controllers.PromotionController.create_promotion(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  def update_promotion(_, %{input: input}, _) do
    case CoreWeb.Controllers.PromotionController.update_promotion(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_promotion_by_service(_, %{input: %{country_service_id: id}}, _) do
    %{service_id: service_id} = Core.Services.get_country_service(id)
    {:ok, Promotions.get_promotion_by_service(service_id)}
  end

  def get_promotions_by_branch(_, %{input: %{branch_id: id}}, _) do
    country_id =
      case Core.BSP.get_branch!(id) do
        %{country_id: id} -> id
        _ -> 1
      end

    Promotions.get_promotions_by_branch(id)
    |> attach_services_to_promotions(country_id)
    |> ok()
  end

  def attach_services_to_promotions(promotions, types, country_id) do
    Enum.reduce(promotions, [], fn promotion, promo_acc ->
      Enum.reduce_while(promotion.service_ids, promo_acc, fn service_id, acc ->
        case Services.get_service(service_id) do
          %{service_type_id: type} ->
            if type in types do
              {:halt, [promotion | acc]}
            else
              {:cont, acc}
            end

          _ ->
            {:cont, acc}
        end
      end)
    end)
    |> attach_services_to_promotions(country_id)
  end

  def attach_services_to_promotions(promotions, country_id) do
    Enum.map(promotions, fn %{branch_id: branch_id} = promotion ->
      services =
        Enum.reduce(promotion.service_ids, [], fn service_id, acc ->
          service = Services.get_service(service_id)
          #        adding country_id and branch_id to service_object
          case Services.get_country_service_by_country_and_service_id(%{
                 country_id: country_id,
                 service_id: service_id
               }) do
            [%{id: cs_id}] ->
              case Services.get_branch_services_by_branch_id(branch_id, cs_id) do
                [%{id: bs_id}] ->
                  service_data =
                    Map.merge(service, %{branch_service_id: bs_id, country_service_id: cs_id})

                  [service_data | acc]

                _ ->
                  acc
              end

            _ ->
              acc
          end
        end)

      grouped_services = BusinessResolver.make_services_grouped(services)
      Map.merge(promotion, %{services: grouped_services})
    end)
  end

  def attach_services_to_promotions(%{promotions: promotions, types: types}) do
    Enum.reduce(promotions, [], fn promotion, promo_acc ->
      Enum.reduce_while(promotion.service_ids, promo_acc, fn service_id, acc ->
        case Services.get_service(service_id) do
          %{service_type_id: type} ->
            if type in types do
              {:halt, [promotion | acc]}
            else
              {:cont, acc}
            end

          _ ->
            {:cont, acc}
        end
      end)
    end)
    |> attach_services_to_promotion()
  end

  def attach_services_to_promotion(promotions) do
    Enum.map(promotions, fn promotion ->
      services =
        Enum.reduce(promotion.service_ids, [], fn service_id, acc ->
          service = Services.get_service(service_id)
          [service | acc]
        end)

      grouped_services = BusinessResolver.make_services_grouped(services)
      Map.merge(promotion, %{services: grouped_services})
    end)
  end

  #  def get_promotions_by_business(_, %{input: %{business_id: id}}, _) do
  #    {:ok, Promotions.get_promotions_by_business(id)}
  #  end

  #  def get_promotion_by_service_and_business(_, %{input: input}, %{context: %{current_user: current_user}}) do
  #    case Jobs.get_job(input.job_id) do
  #      nil -> {:error, ["job doesn't exist"]}
  #      %{inserted_by: user_id, cost: amount} = job  ->
  #        input = Map.merge(input, %{user_id: current_user.id, cmr_id: user_id, amount: amount})
  #        case CoreWeb.Controllers.PromotionController.get_promotions_by(input) do
  #          [] -> {:error, ["promotions doesn't exists"]}
  #          promotions -> {:ok, promotions}
  #          _ -> {:error, ["Unexpected error occurred, try again!"]}
  #        end
  #    end
  #  end
end
