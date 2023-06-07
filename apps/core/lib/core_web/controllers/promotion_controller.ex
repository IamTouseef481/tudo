defmodule CoreWeb.Controllers.PromotionController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.{Accounts, BSP, Jobs, Promotions, Services}
  alias Core.Schemas.Promotion
  alias CoreWeb.Helpers.PromotionHelper

  def create_promotion(input) do
    with {:ok, _last, all} <- PromotionHelper.create_promotion(input),
         %{promotion: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def update_promotion(input) do
    with {:ok, _last, all} <- PromotionHelper.update_promotion(input),
         %{promotion: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def get_deals_by(
        %{country_service_ids: country_service_ids, location: %{lat: lat, long: long}} = input
      ) do
    service_ids = Services.get_service_ids_by_country_service_ids(country_service_ids)

    deals =
      Promotions.get_deals_by(Map.merge(input, %{service_ids: service_ids}))
      |> Enum.uniq_by(& &1.title)

    deals = validate_promotions_radius(deals, {long, lat})
    logger(__MODULE__, Enum.count(deals), :info, __ENV__.line)
    deals = add_branch_in_deals(deals)
    {:ok, deals}
  end

  def get_deals_by(%{location: %{lat: lat, long: long}} = input) do
    deals =
      Promotions.get_deals_by(input)
      |> Enum.uniq_by(& &1.title)

    deals = validate_promotions_radius(deals, {long, lat})
    logger(__MODULE__, Enum.count(deals), :info, __ENV__.line)
    deals = add_branch_in_deals(deals)
    {:ok, deals}
  end

  def get_deals_by(_) do
    {:error,
     ["Multiple Service Provider Subscriptions rules available against this package and Country"]}
  end

  def get_available_promotions(%{used: true, available: true} = input) do
    case Promotions.get_used_and_available_promotions_by(input) do
      [] ->
        {:error, ["You don't have Promotion usage or eigibility in your Subscription package"]}

      promotions ->
        {:ok, promotions}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def get_available_promotions(%{used: true} = input) do
    case Promotions.get_used_promotions_by(input) do
      [] -> {:error, ["You don't have any used Promotion in your Subscription package"]}
      promotions -> {:ok, promotions}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def get_available_promotions(%{available: true} = input) do
    case Promotions.get_available_promotions_by(input) do
      [] -> {:error, ["You don't have any available Promotions in your Subscription package"]}
      promotions -> {:ok, promotions}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def get_available_promotions(input) do
    case Promotions.get_used_and_available_promotions_by(input) do
      promotions -> {:ok, promotions}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def add_branch_in_deals(deals) do
    Enum.map(deals, fn deal ->
      %{location: %{coordinates: {long, lat}}} = branch = BSP.get_branch!(deal.branch_id)

      #         branch = Map.drop(branch, [:discount_type, :licence_issuing_authority, :employees, :city, :business, :branch_services, :__meta__, :__struct__])
      Map.merge(deal, %{branch: Map.merge(branch, %{geo: %{lat: lat, long: long}})})
    end)
  end

  def get_country_id_of_user_for_deals(%{user_id: user_id}) do
    case Accounts.get_user!(user_id) do
      nil ->
        {:error, ["user does not exist!"]}

      %{country_id: country_id} when country_id != nil ->
        {:ok, country_id}

      %{country_id: country_id} when country_id == nil ->
        {:error, ["user's country id doesn't exist"]}

      _ ->
        {:error, ["Something went wrong, unexpected error occurred while retriving User!"]}
    end
  end

  def create_promotion_status(input) do
    if owner_or_manager_validity(input) do
      case Promotions.create_promotion_statuses(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def get_promotions_by(
        %{business_id: business_id, service_ids: service_ids, job_id: job_id} = input
      ) do
    %{location_dest: job_location, arrive_at: job_time} = Jobs.get_job(job_id)
    %{coordinates: cmr_coordinates} = job_location
    job_time = if is_nil(job_time), do: DateTime.utc_now(), else: job_time
    input = Map.merge(input, %{cmr_coordinates: cmr_coordinates, job_time: job_time})

    case service_and_business_validity(business_id, service_ids) do
      {:ok, _s_ids} ->
        case Promotions.get_promotion_by_service(service_ids) do
          [] -> []
          promotions -> validate_promotions(input, promotions)
        end

      {:error, _} ->
        []
    end
  rescue
    _ -> []
  end

  def get_promotions_by(
        %{business_id: business_id, service_id: service_id, job_id: job_id} = input
      ) do
    %{location_dest: job_location, arrive_at: job_time} = Jobs.get_job(job_id)
    %{coordinates: cmr_coordinates} = job_location
    job_time = if is_nil(job_time), do: DateTime.utc_now(), else: job_time
    input = Map.merge(input, %{cmr_coordinates: cmr_coordinates, job_time: job_time})

    case service_and_business_validity(business_id, service_id) do
      {:ok, _data} ->
        case Promotions.get_promotion_by_service(service_id) do
          [] -> []
          promotions -> validate_promotions(input, promotions)
        end

      {:error, _} ->
        []
    end
  rescue
    _ -> []
  end

  def get_promotions_by(
        %{
          business_id: business_id,
          service_id: service_id,
          location_dest: bid_job_location,
          arrive_at: bid_job_time
        } = input
      ) do
    # %{location_dest: job_location, arrive_at: job_time} = Jobs.get_job(job_id)
    %{coordinates: cmr_coordinates} = bid_job_location
    job_time = if is_nil(bid_job_time), do: DateTime.utc_now(), else: bid_job_time
    input = Map.merge(input, %{cmr_coordinates: cmr_coordinates, job_time: job_time})

    case service_and_business_validity(business_id, service_id) do
      {:ok, _data} ->
        case Promotions.get_promotion_by_service(service_id) do
          [] -> []
          promotions -> validate_promotions(input, promotions)
        end

      {:error, _} ->
        []
    end
  rescue
    _ -> []
  end

  def get_promotions_by(
        %{
          business_id: business_id,
          service_ids: service_ids,
          branch_id: branch_id,
          location: %{lat: lat, long: long}
        } = input
      ) do
    job_time = if is_nil(input[:job_time]), do: DateTime.utc_now(), else: input[:job_time]
    input = Map.merge(input, %{cmr_coordinates: {long, lat}, job_time: job_time})

    case service_and_business_validity(business_id, service_ids) do
      {:ok, _data} ->
        case Promotions.get_promotion_by_service(service_ids, branch_id) do
          [] -> []
          promotions -> validate_promotions(input, promotions)
        end

      {:error, _} ->
        []
    end
  end

  def get_promotions_by(
        %{
          business_id: business_id,
          service_id: service_id,
          branch_id: branch_id,
          location: %{lat: lat, long: long}
        } = input
      ) do
    job_time = if is_nil(input[:job_time]), do: DateTime.utc_now(), else: input[:job_time]
    input = Map.merge(input, %{cmr_coordinates: {long, lat}, job_time: job_time})

    case service_and_business_validity(business_id, service_id) do
      {:ok, _data} ->
        case Promotions.get_promotion_by_service(service_id, branch_id) do
          [] -> []
          promotions -> validate_promotions(input, promotions)
        end

      {:error, _} ->
        []
    end
  rescue
    _ -> []
  end

  def validate_promotions(
        %{
          branch_id: _branch_id,
          discountable_price: discountable_price,
          cmr_coordinates: cmr_coordinates,
          job_time: job_time
        } = input,
        promotions
      ) do
    promotions = Enum.filter(promotions, &(&1.promotion_status_id == "active"))

    promotions =
      case Enum.filter(promotions, &(&1.is_combined == false)) do
        [] -> Enum.filter(promotions, & &1.is_combined)
        promotions -> [List.first(promotions)]
      end

    #    promotions = Enum.filter(promotions, fn promotion ->
    #      case Timex.between?(DateTime.utc_now(), promotion.begin_date, promotion.end_date) do
    #        true -> promotion
    #        false ->
    #          Promotions.update_promotion_status(promotion, %{promotion_status_id: "expired"})
    #          false
    #      end
    #    end)
    promotions =
      Enum.filter(promotions, fn promotion ->
        end_date_compare = DateTime.compare(job_time, promotion.end_date)
        start_date_compare = DateTime.compare(job_time, promotion.begin_date)

        if end_date_compare == :gt or start_date_compare == :lt do
          false
        else
          promotion
        end
      end)

    promotions =
      Enum.filter(promotions, fn
        %{expire_after_amount: expire_after_amount, valid_after_amount: valid_after_amount} ->
          Enum.reduce(
            %{valid_after_amount: valid_after_amount, expire_after_amount: expire_after_amount},
            true,
            fn
              {:valid_after_amount, amount}, acc when is_nil(amount) ->
                acc

              {:expire_after_amount, amount}, acc when is_nil(amount) ->
                acc

              {:valid_after_amount, amount}, acc when not is_nil(amount) ->
                discountable_price >= amount and acc

              {:expire_after_amount, amount}, acc when not is_nil(amount) ->
                discountable_price <= expire_after_amount and acc
            end
          )
      end)

    promotions =
      Enum.filter(promotions, fn
        %{max_user_count: max_user_count} when is_nil(max_user_count) ->
          true

        %{max_user_count: max_user_count, id: id} ->
          List.first(Promotions.max_user_count(id, input)) <= max_user_count
      end)

    promotions = Enum.map(promotions, &Map.delete(&1, :branch))

    promotions = validate_promotions_radius(promotions, cmr_coordinates)
    promotions
  end

  def validate_promotions_radius(promotions, cmr_coordinates) do
    Enum.filter(promotions, fn promotion ->
      %{location: branch_location} = BSP.get_branch!(promotion.branch_id)
      %{coordinates: branch_coordinates} = branch_location

      distance_in_kilometers =
        calculate_distance_between_two_coordinates(
          branch_coordinates,
          cmr_coordinates
        )

      if promotion.radius >= distance_in_kilometers do
        promotion
      else
        false
      end
    end)
  end

  defp service_and_business_validity(business_id, service_ids) when is_list(service_ids) do
    s_ids = Promotions.check_service_is_valid(business_id)

    count =
      Enum.reduce(service_ids, 0, fn s_id, acc ->
        if s_id in s_ids,
          do: acc + 1,
          else: acc
      end)

    if count == length(service_ids) do
      {:ok, ["valid"]}
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  defp service_and_business_validity(business_id, service_id) do
    service_ids = Promotions.check_service_is_valid(business_id) |> Enum.uniq()

    if service_id in service_ids do
      {:ok, ["valid"]}
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  def get_promotion_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Promotions.get_promotion_statuses(id) do
        nil -> {:error, ["Invalid Promotion status"]}
        %{} = promotion_status -> {:ok, promotion_status}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def update_promotion_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Promotions.get_promotion_statuses(id) do
        nil -> {:error, ["Invalid Promotion status"]}
        %{} = promotion_status -> Promotions.update_promotion_statuses(promotion_status, input)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_promotion_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Promotions.get_promotion_statuses(id) do
        nil -> {:error, ["Invalid Promotion status"]}
        %{} = promotion_status -> Promotions.delete_promotion_statuses(promotion_status)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def index(conn, _params) do
    promotions = Promotions.list_promotions()
    render(conn, "index.html", promotions: promotions)
  end

  def new(conn, _params) do
    changeset = Promotions.change_promotion(%Promotion{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"promotion" => promotion_params}) do
    case Promotions.create_promotion(promotion_params) do
      {:ok, _promotion} ->
        conn
        |> put_flash(:info, "Promotion created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    promotion = Promotions.get_promotion!(id)
    render(conn, "show.html", promotion: promotion)
  end

  def edit(conn, %{"id" => id}) do
    promotion = Promotions.get_promotion!(id)
    changeset = Promotions.change_promotion(promotion)
    render(conn, "edit.html", promotion: promotion, changeset: changeset)
  end

  def update(conn, %{"id" => id, "promotion" => promotion_params}) do
    promotion = Promotions.get_promotion!(id)

    case Promotions.update_promotion(promotion, promotion_params) do
      {:ok, _promotion} ->
        conn
        |> put_flash(:info, "Promotion updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", promotion: promotion, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    promotion = Promotions.get_promotion!(id)
    {:ok, _promotion} = Promotions.delete_promotion(promotion)

    conn
    |> put_flash(:info, "Promotion deleted successfully.")
  end
end
