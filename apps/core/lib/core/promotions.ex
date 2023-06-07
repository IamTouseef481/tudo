defmodule Core.Promotions do
  @moduledoc """
  The Promotions context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{
    AvailablePromotion,
    Branch,
    Business,
    Deal,
    Promotion,
    PromotionStatuses
  }

  @doc """
  Returns the list of promotions.

  ## Examples

      iex> list_promotions()
      [%Promotion{}, ...]

  """
  def list_promotions do
    Repo.all(Promotion)
  end

  @doc """
  Gets a single promotion.

  Raises `Ecto.NoResultsError` if the Promotion does not exist.

  ## Examples

      iex> get_promotion!(123)
      %Promotion{}

      iex> get_promotion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_promotion!(id), do: Repo.get!(Promotion, id)
  def get_promotion(id), do: Repo.get(Promotion, id)

  def get_promotions_by_branch(id) do
    from(p in Promotion, where: p.branch_id == ^id)
    |> Repo.all()
  end

  def get_active_promotions_count_by_branch(id) do
    from(p in Promotion,
      where: p.branch_id == ^id and p.promotion_status_id == "active",
      select: count(p.id)
    )
    |> Repo.one()
  end

  def get_promotion_by(%{title: title, branch_id: branch_id}) do
    from(p in Promotion, where: p.title == ^title and p.branch_id == ^branch_id)
    |> Repo.all()
  end

  @doc """
    check_service_id_is_valid/1 when is_list service_ids
    Checks if a promotion contains the service_ids

  get_promotion_by_service/1
    Checks if a promotion contains this service_id
  """
  def get_promotion_by_service(service_ids) when is_list(service_ids) do
    from(p in Promotion, where: fragment("? <@ ?", ^service_ids, p.service_ids))
    |> Repo.all()
  end

  def get_promotion_by_service(service_id) do
    from(p in Promotion, where: fragment("? = any (?)", ^service_id, p.service_ids))
    |> Repo.all()
  end

  @doc """
    check_service_id_is_valid/1
    Takes business_id & service_id and checks if
    a business has a service or not. Uses a query with joins
  """
  def check_service_is_valid(business_id, service_ids \\ []) do
    query =
      Business
      |> join(:inner, [bs], br in Branch, on: bs.id == br.business_id)
      |> join(:inner, [_, br], bs in Core.Schemas.BranchService, on: bs.branch_id == br.id)
      |> join(:inner, [_, _, bs], cs in Core.Schemas.CountryService,
        on: bs.country_service_id == cs.id
      )
      |> join(:inner, [_, _, _, cs], srv in Core.Schemas.Service, on: srv.id == cs.service_id)
      |> where([bs, _, _, _, _], bs.id == ^business_id)

    q =
      if service_ids == [],
        do: query |> select([_, _, _, cs, _], cs.service_id),
        #                  |> Repo.all()
        else:
          query
          |> where([_, _, _, cs, _], cs.service_id in ^service_ids)
          |> select([_, _, _, cs, _], cs.service_id)

    #                    |> Repo.all()
    q |> distinct(true) |> Repo.all()
  end

  def get_promotion_by_service(service_ids, branch_id) when is_list(service_ids) do
    from(p in Promotion,
      where: p.branch_id == ^branch_id and fragment("? <@ ?", ^service_ids, p.service_ids)
    )
    |> Repo.all()
  end

  def get_promotion_by_service(service_id, branch_id) do
    from(p in Promotion,
      where: p.branch_id == ^branch_id and fragment("? = any (?)", ^service_id, p.service_ids)
    )
    |> Repo.all()
  end

  #  def get_promotions_by(%{service_id: service_id}) do
  #    from(p in Promotion, where: fragment("? = any (?)", ^service_id,p.service_ids)
  #      and p.promotion_status_id == "active"
  #      and is_nil(p.expiry_count)  # is_nil(expiry_count) or expiry_count<10
  #
  #    )
  #    |> Repo.all()
  #  end

  @doc """
  Creates a promotion.

  ## Examples

      iex> create_promotion(%{field: value})
      {:ok, %Promotion{}}

      iex> create_promotion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_promotion(attrs \\ %{}) do
    %Promotion{}
    |> Promotion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a promotion.

  ## Examples

      iex> update_promotion(promotion, %{field: new_value})
      {:ok, %Promotion{}}

      iex> update_promotion(promotion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_promotion(%Promotion{} = promotion, attrs) do
    promotion
    |> Promotion.changeset(attrs)
    |> Repo.update()
  end

  def update_promotion_status(%Promotion{} = promotion, attrs) do
    promotion
    |> Promotion.update_promotion_status_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Promotion.

  ## Examples

      iex> delete_promotion(promotion)
      {:ok, %Promotion{}}

      iex> delete_promotion(promotion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_promotion(%Promotion{} = promotion) do
    Repo.delete(promotion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking promotion changes.

  ## Examples

      iex> change_promotion(promotion)
      %Ecto.Changeset{source: %Promotion{}}

  """
  def change_promotion(%Promotion{} = promotion) do
    Promotion.changeset(promotion, %{})
  end

  @doc """
  Returns the list of promotion_statuses.

  ## Examples

      iex> list_promotion_statuses()
      [%PromotionStatuses{}, ...]

  """
  def list_promotion_statuses do
    Repo.all(PromotionStatuses)
  end

  @doc """
  Gets a single promotion_statuses.

  Raises `Ecto.NoResultsError` if the Promotion statuses does not exist.

  ## Examples

      iex> get_promotion_statuses!(123)
      %PromotionStatuses{}

      iex> get_promotion_statuses!(456)
      ** (Ecto.NoResultsError)

  """
  def get_promotion_statuses!(id), do: Repo.get!(PromotionStatuses, id)
  def get_promotion_statuses(id), do: Repo.get(PromotionStatuses, id)

  @doc """
  Creates a promotion_statuses.

  ## Examples

      iex> create_promotion_statuses(%{field: value})
      {:ok, %PromotionStatuses{}}

      iex> create_promotion_statuses(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_promotion_statuses(attrs \\ %{}) do
    %PromotionStatuses{}
    |> PromotionStatuses.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a promotion_statuses.

  ## Examples

      iex> update_promotion_statuses(promotion_statuses, %{field: new_value})
      {:ok, %PromotionStatuses{}}

      iex> update_promotion_statuses(promotion_statuses, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_promotion_statuses(%PromotionStatuses{} = promotion_statuses, attrs) do
    promotion_statuses
    |> PromotionStatuses.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PromotionStatuses.

  ## Examples

      iex> delete_promotion_statuses(promotion_statuses)
      {:ok, %PromotionStatuses{}}

      iex> delete_promotion_statuses(promotion_statuses)
      {:error, %Ecto.Changeset{}}

  """
  def delete_promotion_statuses(%PromotionStatuses{} = promotion_statuses) do
    Repo.delete(promotion_statuses)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking promotion_statuses changes.

  ## Examples

      iex> change_promotion_statuses(promotion_statuses)
      %Ecto.Changeset{source: %PromotionStatuses{}}

  """
  def change_promotion_statuses(%PromotionStatuses{} = promotion_statuses) do
    PromotionStatuses.changeset(promotion_statuses, %{})
  end

  @doc """
  Returns the list of deals.

  ## Examples

      iex> list_deals()
      [%Deal{}, ...]

  """
  def list_deals do
    Repo.all(Deal)
  end

  @doc """
  Gets a single deal.

  Raises `Ecto.NoResultsError` if the Deal does not exist.

  ## Examples

      iex> get_deal!(123)
      %Deal{}

      iex> get_deal!(456)
      ** (Ecto.NoResultsError)

  """
  def get_deal!(id), do: Repo.get!(Deal, id)

  def get_deals_by(%{service_ids: service_ids} = input) do
    location = CoreWeb.Utils.CommonFunctions.encode_location(input.location)

    query =
      from(p in Promotion,
        join: b in Branch,
        on: b.id == p.branch_id,
        join: bus in Business,
        on: bus.id == b.business_id,
        where:
          p.promotion_status_id == "active" and
            bus.user_id != ^input.user_id and
            p.expiry_count >
              fragment(
                "select count(id) from deals where user_id = ? and promotion_id = ? and service_id = any (?)",
                ^input.user_id,
                p.id,
                ^service_ids
              ) and
            fragment("? && ?", p.service_ids, ^service_ids) and
            fragment("filter_zone(?,?)", p.zone_ids, ^location),
        order_by: [desc: p.value]
      )

    case input do
      %{favourite: fav} ->
        if fav,
          do: from(p in query, where: p.favourite),
          else: from(p in query, where: p.favourite == false)

      _ ->
        query
    end
    |> Repo.all()
  end

  def get_deals_by(%{service_id: service_id} = input) do
    location = CoreWeb.Utils.CommonFunctions.encode_location(input.location)

    query =
      from(p in Promotion,
        join: b in Branch,
        on: b.id == p.branch_id,
        join: bus in Business,
        on: bus.id == b.business_id,
        where:
          p.promotion_status_id == "active" and
            bus.user_id != ^input.user_id and
            p.expiry_count >
              fragment(
                "select count(id) from deals where user_id = ? and promotion_id = ? and service_id = ?",
                ^input.user_id,
                p.id,
                ^service_id
              ) and
            fragment("? = any (?)", ^service_id, p.service_ids) and
            fragment("filter_zone(?,?)", p.zone_ids, ^location),
        order_by: [desc: p.value]
      )

    case input do
      %{favourite: fav} ->
        if fav,
          do: from(p in query, where: p.favourite),
          else: from(p in query, where: p.favourite == false)

      _ ->
        query
    end
    |> Repo.all()
  end

  def get_deals_by(%{user_id: user_id} = input) do
    location = CoreWeb.Utils.CommonFunctions.encode_location(input.location)

    query =
      from(p in Promotion,
        join: b in Branch,
        on: b.id == p.branch_id,
        join: bus in Business,
        on: bus.id == b.business_id,
        where:
          p.promotion_status_id == "active" and
            bus.user_id != ^user_id and
            p.expiry_count >
              fragment(
                "select count(id) from deals where user_id = ? and promotion_id = ?",
                ^user_id,
                p.id
              ) and
            fragment("filter_zone(?,?)", p.zone_ids, ^location),
        order_by: [desc: p.value]
      )

    case input do
      %{favourite: fav} ->
        if fav,
          do: from(p in query, where: p.favourite),
          else: from(p in query, where: p.favourite == false)

      _ ->
        query
    end
    |> Repo.all()
  end

  def get_deals_by(input) do
    location = CoreWeb.Utils.CommonFunctions.encode_location(input.location)

    query =
      from(p in Promotion,
        join: b in Branch,
        on: b.id == p.branch_id,
        # bus.user_id != ^user_id and
        # p.expiry_count >
        #   fragment(
        #     "select count(id) from deals where user_id = ? and promotion_id = ?",
        #     ^user_id,
        #     p.id
        #   ) and
        where:
          p.promotion_status_id == "active" and
            fragment("filter_zone(?,?)", p.zone_ids, ^location),
        order_by: [desc: p.value]
      )

    case input do
      %{favourite: fav} ->
        if fav,
          do: from(p in query, where: p.favourite),
          else: from(p in query, where: p.favourite == false)

      _ ->
        query
    end
    |> Repo.all()
  end

  def max_user_count(promotion_id, %{cmr_id: cmr_id, service_id: service_id}) do
    from(d in Deal,
      where:
        d.user_id == ^cmr_id and d.promotion_id == ^promotion_id and d.service_id == ^service_id,
      select: count(d.id)
    )
    |> Repo.all()
  end

  def max_user_count(promotion_id, %{cmr_id: cmr_id}) do
    from(d in Deal,
      where: d.user_id == ^cmr_id and d.promotion_id == ^promotion_id,
      select: count(d.id)
    )
    |> Repo.all()
  end

  @doc """
  Creates a deal.

  ## Examples

      iex> create_deal(%{field: value})
      {:ok, %Deal{}}

      iex> create_deal(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_deal(attrs \\ %{}) do
    %Deal{}
    |> Deal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a deal.

  ## Examples

      iex> update_deal(deal, %{field: new_value})
      {:ok, %Deal{}}

      iex> update_deal(deal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_deal(%Deal{} = deal, attrs) do
    deal
    |> Deal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Deal.

  ## Examples

      iex> delete_deal(deal)
      {:ok, %Deal{}}

      iex> delete_deal(deal)
      {:error, %Ecto.Changeset{}}

  """
  def delete_deal(%Deal{} = deal) do
    Repo.delete(deal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking deal changes.

  ## Examples

      iex> change_deal(deal)
      %Ecto.Changeset{source: %Deal{}}

  """
  def change_deal(%Deal{} = deal) do
    Deal.changeset(deal, %{})
  end

  @doc """
  Returns the list of available_promotions.

  ## Examples

      iex> list_available_promotions()
      [%AvailablePromotion{}, ...]

  """
  def list_available_promotions do
    Repo.all(AvailablePromotion)
  end

  @doc """
  Gets a single available_promotion.

  Raises `Ecto.NoResultsError` if the Available promotion does not exist.

  ## Examples

      iex> get_available_promotion!(123)
      %AvailablePromotion{}

      iex> get_available_promotion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_available_promotion!(id), do: Repo.get!(AvailablePromotion, id)

  def get_available_promotions_by_branch(id) do
    from(p in AvailablePromotion, where: p.branch_id == ^id and p.active)
    |> Repo.all()
  end

  def get_available_promotions_for_creation(%{
        radius: radius,
        begin_date: begin_date,
        branch_id: branch_id
      }) do
    from(p in AvailablePromotion,
      where:
        p.branch_id == ^branch_id and p.active and
          p.begin_at <= ^begin_date and p.expire_at >= ^begin_date and
          p.broadcast_range >= ^radius and is_nil(p.used_at)
    )
    |> Repo.all()
  end

  def get_available_promotions_for_creation(%{
        radius: radius,
        begin_date: begin_date,
        business_id: business_id
      }) do
    from(p in AvailablePromotion,
      where:
        p.business_id == ^business_id and p.active and
          p.begin_at <= ^begin_date and p.expire_at >= ^begin_date and
          p.broadcast_range >= ^radius and is_nil(p.used_at)
    )
    |> Repo.all()
  end

  def get_available_promotions_by(%{
        radius: radius,
        begin_date: begin_date,
        end_date: end_date,
        branch_id: branch_id,
        business_id: business_id
      }) do
    from(p in AvailablePromotion,
      where:
        (p.branch_id == ^branch_id or p.business_id == ^business_id) and p.active and
          p.begin_at <= ^begin_date and p.expire_at >= ^begin_date and
          p.begin_at <= ^end_date and p.expire_at >= ^end_date and
          p.broadcast_range >= ^radius and is_nil(p.used_at)
    )
    |> Repo.all()
  end

  def get_available_promotions_by(%{
        radius: radius,
        begin_date: begin_date,
        end_date: end_date,
        business_id: business_id
      }) do
    from(p in AvailablePromotion,
      where:
        p.business_id == ^business_id and not p.additional and p.active and
          p.begin_at <= ^begin_date and p.expire_at >= ^begin_date and
          p.begin_at <= ^end_date and p.expire_at >= ^end_date and
          p.broadcast_range >= ^radius and is_nil(p.used_at)
    )
    |> Repo.all()
  end

  def get_available_promotions_by(%{
        radius: radius,
        begin_date: begin_date,
        end_date: end_date,
        branch_id: branch_id
      }) do
    from(p in AvailablePromotion,
      where:
        p.branch_id == ^branch_id and p.additional and p.active and
          p.begin_at <= ^begin_date and p.expire_at >= ^begin_date and
          p.begin_at <= ^end_date and p.expire_at >= ^end_date and
          p.broadcast_range >= ^radius and is_nil(p.used_at)
    )
    |> Repo.all()
  end

  def get_available_promotions_by(%{
        radius: radius,
        branch_id: branch_id,
        business_id: business_id
      }) do
    current_time = DateTime.utc_now()

    from(p in AvailablePromotion,
      where:
        (p.branch_id == ^branch_id or p.business_id == ^business_id) and p.active and
          p.begin_at <= ^current_time and p.expire_at >= ^current_time and
          p.broadcast_range >= ^radius and is_nil(p.used_at)
    )
    |> Repo.all()
  end

  def get_available_promotions_by(%{radius: radius, business_id: business_id}) do
    current_time = DateTime.utc_now()

    from(p in AvailablePromotion,
      where:
        p.business_id == ^business_id and
          p.begin_at <= ^current_time and p.expire_at >= ^current_time and p.active and
          p.broadcast_range >= ^radius and is_nil(p.used_at)
    )
    |> Repo.all()
  end

  def get_available_promotions_by(%{radius: radius, branch_id: branch_id}) do
    current_time = DateTime.utc_now()

    from(p in AvailablePromotion,
      where:
        p.branch_id == ^branch_id and
          p.begin_at <= ^current_time and p.expire_at >= ^current_time and p.active and
          p.broadcast_range >= ^radius and is_nil(p.used_at)
    )
    |> Repo.all()
  end

  #  available promotions
  def get_available_promotions_by(%{business_id: business_id, branch_id: branch_id}) do
    current_time = DateTime.utc_now()

    from(p in AvailablePromotion,
      where:
        (p.branch_id == ^branch_id or p.business_id == ^business_id) and p.active and
          p.begin_at <= ^current_time and p.expire_at >= ^current_time and
          is_nil(p.used_at)
    )
    |> Repo.all()
  end

  def get_available_promotions_by(%{branch_id: branch_id}) do
    current_time = DateTime.utc_now()

    from(p in AvailablePromotion,
      where:
        p.branch_id == ^branch_id and is_nil(p.used_at) and p.active and
          p.begin_at <= ^current_time and p.expire_at >= ^current_time
    )
    |> Repo.all()
  end

  def get_available_promotions_by(%{business_id: business_id}) do
    current_time = DateTime.utc_now()

    from(p in AvailablePromotion,
      where:
        p.business_id == ^business_id and is_nil(p.used_at) and p.active and
          p.begin_at <= ^current_time and p.expire_at >= ^current_time
    )
    |> Repo.all()
  end

  def get_used_promotions_by(%{business_id: business_id, branch_id: branch_id}) do
    from(p in AvailablePromotion,
      where:
        not is_nil(p.used_at) and p.active and
          (p.branch_id == ^branch_id or p.business_id == ^business_id)
    )
    |> Repo.all()
  end

  def get_used_promotions_by(%{branch_id: branch_id}) do
    from(p in AvailablePromotion,
      where: not is_nil(p.used_at) and p.active and p.branch_id == ^branch_id
    )
    |> Repo.all()
  end

  def get_used_promotions_by(%{business_id: business_id}) do
    from(p in AvailablePromotion,
      where: not is_nil(p.used_at) and p.business_id == ^business_id and p.active
    )
    |> Repo.all()
  end

  def get_used_and_available_promotions_by(%{business_id: business_id, branch_id: branch_id}) do
    current_time = DateTime.utc_now()

    from(p in AvailablePromotion,
      where:
        (p.branch_id == ^branch_id or p.business_id == ^business_id) and p.active and
          p.begin_at <= ^current_time and p.expire_at >= ^current_time
    )
    |> Repo.all()
  end

  def get_used_and_available_promotions_by(%{branch_id: branch_id}) do
    current_time = DateTime.utc_now()

    from(p in AvailablePromotion,
      where:
        p.branch_id == ^branch_id and p.active and
          p.begin_at <= ^current_time and p.expire_at >= ^current_time
    )
    |> Repo.all()
  end

  def get_used_and_available_promotions_by(%{business_id: business_id}) do
    current_time = DateTime.utc_now()

    from(p in AvailablePromotion,
      where:
        p.business_id == ^business_id and p.active and
          p.begin_at <= ^current_time and p.expire_at >= ^current_time
    )
    |> Repo.all()
  end

  def get_available_promotions_by_pricing(promotion_pricing_id) do
    from(p in AvailablePromotion,
      where: p.promotion_pricing_id == ^promotion_pricing_id,
      order_by: [desc: p.inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a available_promotion.

  ## Examples

      iex> create_available_promotion(%{field: value})
      {:ok, %AvailablePromotion{}}

      iex> create_available_promotion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_available_promotion(attrs \\ %{}) do
    %AvailablePromotion{}
    |> AvailablePromotion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a available_promotion.

  ## Examples

      iex> update_available_promotion(available_promotion, %{field: new_value})
      {:ok, %AvailablePromotion{}}

      iex> update_available_promotion(available_promotion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_available_promotion(%AvailablePromotion{} = available_promotion, attrs) do
    available_promotion
    |> AvailablePromotion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a available_promotion.

  ## Examples

      iex> delete_available_promotion(available_promotion)
      {:ok, %AvailablePromotion{}}

      iex> delete_available_promotion(available_promotion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_available_promotion(%AvailablePromotion{} = available_promotion) do
    Repo.delete(available_promotion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking available_promotion changes.

  ## Examples

      iex> change_available_promotion(available_promotion)
      %Ecto.Changeset{source: %AvailablePromotion{}}

  """
  def change_available_promotion(%AvailablePromotion{} = available_promotion) do
    AvailablePromotion.changeset(available_promotion, %{})
  end
end
