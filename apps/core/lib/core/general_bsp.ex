defmodule Core.GeneralBsp do
  @moduledoc """
  The BSP context.
  """
  import Ecto.Query, warn: false

  alias Core.Schemas.{
    Branch,
    BranchService,
    Business,
    BusinessType,
    CountryService,
    RawBusiness,
    Service,
    ServiceGroup,
    ServiceSetting,
    ServiceType,
    User,
    UserStatuses
  }

  #  -------------------------- just for test search for guest users ------------------------------
  defp general_bsp_search do
    from(b in Branch,
      join: ut in UserStatuses,
      on: b.status_id == ut.id,
      join: bt in BusinessType,
      on: b.business_type_id == bt.id,
      join: bus in Business,
      on: bus.id == b.business_id,
      join: bs in BranchService,
      on: b.id == bs.branch_id,
      join: cs in CountryService,
      on: cs.id == bs.country_service_id,
      join: ss in ServiceSetting,
      on: ss.country_service_id == cs.id,
      join: s in Service,
      on: s.id == cs.service_id,
      join: sg in ServiceGroup,
      on: sg.id == s.service_group_id,
      join: st in ServiceType,
      on: st.id == s.service_type_id,
      join: u in User,
      on: bus.user_id == u.id
    )
  end

  def search(params) do
    branches =
      Task.async(fn ->
        get_branches_for_general_search(params)
      end)
      |> Task.await(:infinity)

    branch_count =
      Task.async(fn ->
        get_count_of_branches_for_general_search(params)
      end)
      |> Task.await(:infinity)

    raw_count =
      Task.async(fn ->
        raw_business_union_query_for_count(params)
      end)
      |> Task.await(:infinity)

    count = (branch_count || 0) + (raw_count || 0)
    %{count: count, branches: branches}
  end

  def get_count_of_branches_for_general_search(params) do
    general_bsp_search()
    |> then(fn query ->
      if params[:location] && params[:distance],
        do: query |> calculate_distance_clause(params[:location], params[:distance]),
        else: query
    end)
    |> then(fn query ->
      if Map.get(params, :text_search),
        do: query |> general_bsp_search_query(params),
        else: query
    end)
    |> then(fn query -> check_has_contact_info(query, params[:has_contact_info]) end)
    |> select([b], count(fragment("DISTINCT ?", b.id)))
    |> Core.Repo.one()
  end

  def raw_business_union_query_for_count(params) do
    RawBusiness
    |> join(:left, [b], us in UserStatuses, on: b.status_id == us.id)
    |> join(:left, [b], bt in BusinessType, on: b.business_type_id == bt.id)
    |> where([b], b.is_claimed != true)
    |> select([b], count(fragment("DISTINCT ?", b.id)))
    |> then(fn query ->
      query |> calculate_distance_clause(params[:location], params[:distance])
    end)
    |> then(fn query ->
      if Map.get(params, :text_search),
        do: query |> raw_business_search_query(params),
        else: query
    end)
    |> then(fn query ->
      check_has_contact_info_for_raw_business(query, params[:has_contact_info])
    end)
    |> Core.Repo.one()
  end

  def get_branches_for_general_search(params) do
    general_bsp_search()
    |> then(fn query ->
      if params[:location] && params[:distance],
        do: query |> calculate_distance_clause(params[:location], params[:distance]),
        else: query
    end)
    |> then(fn query ->
      if Map.get(params, :text_search),
        do: query |> general_bsp_search_query(params),
        else: query
    end)
    |> then(fn query -> check_has_contact_info(query, params[:has_contact_info]) end)
    |> general_bsp_search_select(params[:location])
    |> union(^raw_business_union_query(params))
    |> order_by([_], asc: fragment("distance"))
    |> offset(^params.offset)
    |> limit(^params.limit)
    |> Core.Repo.all()
  end

  defp raw_business_union_query(params) do
    RawBusiness
    |> join(:left, [b], us in UserStatuses, on: b.status_id == us.id)
    |> join(:left, [b], bt in BusinessType, on: b.business_type_id == bt.id)
    |> where([b], b.is_claimed != true)
    |> distinct()
    |> raw_business_select(params[:location])
    |> then(fn query ->
      query |> calculate_distance_clause(params[:location], params[:distance])
    end)
    |> then(fn query ->
      if Map.get(params, :text_search),
        do: query |> raw_business_search_query(params),
        else: query
    end)
    |> then(fn query ->
      check_has_contact_info_for_raw_business(query, params[:has_contact_info])
    end)

    #    after updating elixir > 1.12 these lines will be used instead of bare anonymus function
    #    |> then(fn query -> if location && distance, do: query |> calculate_distance_clause(location, distance), else: query end)
    #    |> then(fn query -> if search, do: query |> raw_business_search_query(search), else: query end)
  end

  defp distinct(query), do: query |> distinct([b], b.id)

  defp general_bsp_search_query(query, %{text_search: search} = params) when search != "" do
    search = String.replace(search, ~r/\s+/, " ")

    cond do
      Map.get(params, :is_exact_search) ->
        general_bsp_exact_search(query, params)

      String.contains?(search, "*") ->
        String.replace(search, "*", "%") |> search_with_asytric_wildcard(query)

      String.contains?(search, "-") ->
        split_string(search) |> search_with_hyphen_wildcard(query)

      String.starts_with?(search, "\"") && String.ends_with?(search, "\"") ->
        String.trim(search, "\"") |> double_quote_search(query)

      true ->
        general_bsp_full_text_search(query, params)
    end
  end

  defp general_bsp_search_query(query, _), do: query

  def split_string(string) do
    list_of_strings = String.split(string)

    with_hyphen_list =
      Enum.filter(list_of_strings, fn string ->
        String.starts_with?(string, "-")
      end)

    without_hyphen_list =
      Enum.filter(list_of_strings, fn string ->
        !String.starts_with?(string, "-")
      end)

    %{with_hyphen_list: with_hyphen_list, without_hyphen_list: without_hyphen_list}
  end

  defp check_has_contact_info(query, true) do
    query
    |> where([b], not is_nil(b.phone))
  end

  defp check_has_contact_info(query, false) do
    query
    |> where([b], b.phone == "" or is_nil(b.phone))
  end

  defp check_has_contact_info(query, _), do: query

  defp search_with_hyphen_wildcard(params, query) do
    with_hyphen =
      Enum.join(params.with_hyphen_list, " ")
      |> String.replace("-", "")
      |> String.split()

    without_hyphen = Enum.join(params.without_hyphen_list, " ")

    make_query(query, with_hyphen)
    |> where(
      [b, _, _, _, _, _, _, s, sg, st, _],
      fragment("? ilike ?", b.name, ^"%#{without_hyphen}%") or
        fragment("? ilike ?", b.phone, ^"%#{without_hyphen}%") or
        fragment("? ilike ?", b.description, ^"%#{without_hyphen}%") or
        fragment("? ilike ?", s.name, ^"%#{without_hyphen}%") or
        fragment("? ilike ?", sg.name, ^"%#{without_hyphen}%") or
        fragment("? ilike ?", st.id, ^"%#{without_hyphen}%") or
        fragment("? ilike ?", st.description, ^"%#{without_hyphen}%")
    )
  end

  # making this query param for discarding muultiple words from string. For Example: Mastang -cars -horse.

  defp make_query(query, with_hyphen) do
    Enum.reduce(with_hyphen, query, fn q, acc ->
      acc
      |> where(
        [b, _, _, _, _, _, _, s, sg, st, _],
        fragment("? not ilike ?", b.name, ^"%#{q}%")
      )
      |> where(
        [b, _, _, _, _, _, _, s, sg, st, _],
        fragment("? not ilike ?", b.phone, ^"%#{q}%")
      )
      |> where(
        [b, _, _, _, _, _, _, s, sg, st, _],
        fragment("? not ilike ?", b.description, ^"%#{q}%")
      )
      |> where(
        [b, _, _, _, _, _, _, s, sg, st, _],
        fragment("? not ilike ?", sg.name, ^"%#{q}%")
      )
      |> where(
        [b, _, _, _, _, _, _, s, sg, st, _],
        fragment("? not ilike ?", st.id, ^"%#{q}%")
      )
      |> where(
        [b, _, _, _, _, _, _, s, sg, st, _],
        fragment("? not ilike ?", st.description, ^"%#{q}%")
      )
      |> where(
        [b, _, _, _, _, _, _, s, sg, st, _],
        fragment("? not ilike ?", s.name, ^"%#{q}%")
      )
    end)
  end

  defp search_with_asytric_wildcard(search, query) do
    query
    |> where(
      [b, _, _, _, _, _, _, s, sg, st],
      fragment("? ilike ?", b.name, ^search) or
        fragment("? ilike ?", b.phone, ^search) or
        fragment("? ilike ?", b.description, ^search) or
        fragment("? ilike ?", sg.name, ^search) or
        fragment("? ilike ?", st.id, ^search) or
        fragment("? ilike ?", st.description, ^search) or
        fragment("? ilike ?", s.name, ^search)
    )
  end

  defp general_bsp_exact_search(query, %{text_search: search, is_exact_search: _is_exact_search}) do
    query
    |> where(
      [b, _, _, _, _, _, _, s, sg, st],
      fragment("? ilike ?", b.name, ^"#{search}") or
        fragment("? ilike ?", b.phone, ^"#{search}") or
        fragment("? ilike ?", b.description, ^"#{search}") or
        fragment("? ilike ?", sg.name, ^"#{search}") or
        fragment("? ilike ?", st.id, ^"#{search}") or
        fragment("? ilike ?", st.description, ^"#{search}") or
        fragment("? ilike ?", s.name, ^"#{search}")
    )
  end

  defp double_quote_search(search, query) do
    query
    |> where(
      [b, _, _, _, _, _, _, s, sg, st],
      fragment("? ilike ?", b.name, ^"#{search}") or
        fragment("? ilike ?", b.phone, ^"#{search}") or
        fragment("? ilike ?", b.description, ^"#{search}") or
        fragment("? ilike ?", sg.name, ^"#{search}") or
        fragment("? ilike ?", st.id, ^"#{search}") or
        fragment("? ilike ?", st.description, ^"#{search}") or
        fragment("? ilike ?", s.name, ^"#{search}")
    )
  end

  defp general_bsp_full_text_search(query, %{text_search: search}) do
    query
    |> where(
      [b, _, _, _, _, _, _, s, sg, st],
      fragment("? @@ to_tsquery('english', ?)", b.search_tsvector, ^prefix_search(search)) or
        fragment("? @@ to_tsquery('english', ?)", s.search_tsvector, ^prefix_search(search)) or
        fragment("? @@ to_tsquery('english', ?)", sg.search_tsvector, ^prefix_search(search)) or
        fragment("? @@ to_tsquery('english', ?)", st.search_tsvector, ^prefix_search(search))
    )
  end

  defp general_bsp_search_select(query, location) do
    location =
      if is_nil(location) do
        %{long: nil, lat: nil}
      else
        location
      end

    query
    |> select(
      [b, us, bt, ..., u],
      %{
        distance:
          fragment(
            "SELECT ST_DistanceSphere(
            ?,
            ST_SetSRID(ST_MakePoint(?, ?),4326)
            )/1000
            as distance",
            b.location,
            ^location[:long],
            ^location[:lat]
          ),
        branch_location: b.location,
        id: b.id,
        general_liability_insured: b.general_liability_insured,
        employees_count: b.employees_count,
        name: b.name,
        phone: b.phone,
        rating: b.rating,
        settings: b.settings,
        rating_count: b.rating_count,
        surety_bonded: b.surety_bonded,
        other_details: b.other_details,
        profile_pictures: b.profile_pictures,
        is_head_office: b.is_head_office,
        custom_license_issuing_authority: b.custom_license_issuing_authority,
        auto_assign: b.auto_assign,
        location: b.location,
        licence_no: b.licence_no,
        est_year: b.est_year,
        is_active: b.is_active,
        description: b.description,
        personal_identification: b.personal_identification,
        geo: nil,
        address: b.address,
        licence_issuing_authority_id: b.licence_issuing_authority_id,
        status: us,
        business_type: bt,
        business_id: b.business_id,
        city_id: b.city_id,
        owner_name: nil,
        email: u.email,
        alternate_email: nil,
        raw_phone_details: nil,
        website: nil,
        street_address: nil,
        role: nil,
        city: nil,
        zip_code: nil,
        alternate_phone1: nil,
        alternate_phone2: nil,
        primary_naics_description: nil,
        country_id: b.country_id,
        business_type_id: b.business_type_id,
        zone_ids: b.zone_ids,
        licence_expiry_date: b.licence_expiry_date,
        licence_photos: b.licence_photos,
        is_raw: false,
        is_claimed: nil
      }
    )
  end

  defp raw_business_select(query, location) do
    location =
      if is_nil(location) do
        %{long: nil, lat: nil}
      else
        location
      end

    query
    |> select(
      [b, us, bt],
      %{
        distance:
          fragment(
            "SELECT ST_DistanceSphere(
          ?,
          ST_SetSRID(ST_MakePoint(?, ?),4326)
          )/1000
          as distance",
            b.location,
            ^location[:long],
            ^location[:lat]
          ),
        branch_location: b.location,
        id: b.id,
        general_liability_insured: b.general_liability_insured,
        employees_count: b.employees_count,
        name: b.name,
        phone: b.phone,
        rating: b.rating,
        settings: b.settings,
        rating_count: b.rating_count,
        surety_bonded: b.surety_bonded,
        other_details: b.other_details,
        profile_pictures: b.profile_pictures,
        is_head_office: b.is_head_office,
        custom_license_issuing_authority: b.custom_license_issuing_authority,
        auto_assign: b.auto_assign,
        location: b.location,
        licence_no: b.licence_no,
        est_year: b.est_year,
        is_active: b.is_active,
        description: b.business_profile_info,
        personal_identification: b.personal_identification,
        geo: nil,
        address: b.address,
        licence_issuing_authority_id: nil,
        status: us,
        business_type: bt,
        business_id: nil,
        city_id: nil,
        owner_name: b.owner_name,
        email: b.email,
        alternate_email: b.alternate_email,
        raw_phone_details: b.raw_phone_details,
        website: b.website,
        street_address: b.street_address,
        role: b.role,
        city: b.city,
        zip_code: b.zip_code,
        alternate_phone1: b.alternate_phone1,
        alternate_phone2: b.alternate_phone2,
        primary_naics_description: b.primary_naics_description,
        country_id: nil,
        business_type_id: nil,
        zone_ids: nil,
        licence_expiry_date: nil,
        licence_photos: nil,
        is_raw: true,
        is_claimed: b.is_claimed
      }
    )
  end

  defp raw_business_search_query(query, %{text_search: search} = params) when search != "" do
    cond do
      Map.get(params, :is_exact_search) ->
        raw_bsp_exact_search(query, params)

      String.contains?(search, "*") ->
        String.replace(search, "*", "%") |> raw_bsp_search_with_asytric_wildcard(query)

      String.contains?(search, "-") ->
        split_string(search) |> raw_bsp_search_with_hyphen_wildcard(query)

      String.starts_with?(search, "\"") && String.ends_with?(search, "\"") ->
        String.trim(search, "\"") |> raw_bsp_double_quote_search(query)

      true ->
        raw_bsp_full_text_search(query, search)
    end
  end

  defp raw_business_search_query(query, _), do: query

  defp raw_bsp_search_with_asytric_wildcard(search, query) do
    query
    |> where(
      [r_b],
      fragment("? ilike ?", r_b.name, ^search) or
        fragment("? ilike ?", r_b.phone, ^search) or
        fragment("? ilike ?", r_b.business_profile_info, ^search)
    )
  end

  defp check_has_contact_info_for_raw_business(query, true) do
    query
    |> where([r_b], not is_nil(r_b.phone))
  end

  defp check_has_contact_info_for_raw_business(query, false) do
    query
    |> where([r_b], r_b.phone == "" or is_nil(r_b.phone))
  end

  defp check_has_contact_info_for_raw_business(query, _), do: query

  defp raw_bsp_exact_search(query, %{text_search: search, is_exact_search: _is_exact_search}) do
    query
    |> where(
      [r_b],
      fragment("? ilike ?", r_b.name, ^"#{search}") or
        fragment("? ilike ?", r_b.phone, ^"#{search}") or
        fragment("? ilike ?", r_b.business_profile_info, ^"#{search}")
    )
  end

  defp raw_bsp_double_quote_search(search, query) do
    query
    |> where(
      [r_b],
      fragment("? ilike ?", r_b.name, ^"#{search}") or
        fragment("? ilike ?", r_b.phone, ^"#{search}") or
        fragment("? ilike ?", r_b.business_profile_info, ^"#{search}")
    )
  end

  defp raw_bsp_search_with_hyphen_wildcard(params, query) do
    with_hyphen =
      Enum.join(params.with_hyphen_list, " ") |> String.replace("-", "") |> String.split()

    without_hyphen = Enum.join(params.without_hyphen_list, " ")

    make_query_for_raw_business(query, with_hyphen)
    |> where(
      [r_b],
      fragment("? ilike ?", r_b.name, ^"%#{without_hyphen}%") or
        fragment("? ilike ?", r_b.phone, ^"%#{without_hyphen}%") or
        fragment("? ilike ?", r_b.business_profile_info, ^"%#{without_hyphen}%")
    )
  end

  # making this query param for discarding muultiple words from string. For Example: Mastang -cars -horse.
  defp make_query_for_raw_business(query, with_hyphen) do
    Enum.reduce(with_hyphen, query, fn q, acc ->
      acc
      |> where(
        [r_b],
        fragment("? not ilike ?", r_b.name, ^"%#{q}%")
      )
      |> where(
        [r_b],
        fragment("? not ilike ?", r_b.phone, ^"%#{q}%")
      )
      |> where(
        [r_b],
        fragment("? not ilike ?", r_b.business_profile_info, ^"%#{q}%")
      )
    end)
  end

  defp raw_bsp_full_text_search(query, search) when search != "" do
    query
    |> where(
      [r_b],
      fragment("? @@ to_tsquery('english', ?)", r_b.search_tsvector, ^prefix_search(search))
    )
  end

  defp calculate_distance_clause(query, nil, _distance), do: query

  defp calculate_distance_clause(query, location, distance) do
    query
    |> where(
      [b],
      fragment(
        "SELECT ST_DistanceSphere(
            ?,
            ST_SetSRID(ST_MakePoint(?, ?),4326)
            )/1000 <= ?",
        b.location,
        ^location[:long],
        ^location[:lat],
        ^distance
      )
    )
  end

  def prefix_search(term) when term != "" do
    term
    |> String.trim(" ")
    |> String.replace(~r/\W+/u, ":*|")
    |> String.trim(":*|")
    |> Kernel.<>(":*")
  end

  def get_raw_business_by_id(id) do
    RawBusiness
    |> where([r_b], r_b.id == ^id)
    |> limit(1)
    |> Core.Repo.all()
  end

  def location(id) do
    Branch
    |> where([b], b.id == ^id)
    |> select([b], b.location)
    |> Core.Repo.one()
  end
end
