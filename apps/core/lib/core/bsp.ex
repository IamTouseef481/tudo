defmodule Core.BSP do
  @moduledoc """
  The BSP context.
  """

  import Ecto.Query, warn: false
  import CoreWeb.Utils.Paginator, only: [get_config: 1]
  alias Core.Repo
  alias CoreWeb.Utils.CommonFunctions

  alias Core.Schemas.{
    Branch,
    BranchService,
    Business,
    BusinessType,
    Calendar,
    CashPayment,
    CountryService,
    Dropdown,
    Employee,
    Invoice,
    Job,
    Service,
    ServiceSetting,
    Setting,
    TermsAndCondition,
    User
  }

  def location(id) do
    Branch
    |> where([b], b.id == ^id)
    |> select([b], b.location)
    |> Repo.all()
  end

  def list_business_types, do: Repo.all(BusinessType)

  def get_business_type!(id), do: Repo.get!(BusinessType, id)
  def get_business_type(id), do: Repo.get(BusinessType, id)

  def create_business_type(attrs \\ %{}) do
    %BusinessType{}
    |> BusinessType.changeset(attrs)
    |> Repo.insert()
  end

  def update_business_type(%BusinessType{} = business_type, attrs) do
    business_type
    |> BusinessType.changeset(attrs)
    |> Repo.update()
  end

  def delete_business_type(%BusinessType{} = business_type), do: Repo.delete(business_type)

  def change_business_type(%BusinessType{} = business_type),
    do: BusinessType.changeset(business_type, %{})

  def list_terms_and_conditions, do: Repo.all(TermsAndCondition)

  def get_terms_and_condition!(id), do: Repo.get!(TermsAndCondition, id)

  def create_terms_and_condition(attrs \\ %{}) do
    %TermsAndCondition{}
    |> TermsAndCondition.changeset(attrs)
    |> Repo.insert()
  end

  def update_terms_and_condition(%TermsAndCondition{} = terms_and_condition, attrs) do
    terms_and_condition
    |> TermsAndCondition.changeset(attrs)
    |> Repo.update()
  end

  def delete_terms_and_condition(%TermsAndCondition{} = terms_and_condition),
    do: Repo.delete(terms_and_condition)

  def change_terms_and_condition(%TermsAndCondition{} = terms_and_condition),
    do: TermsAndCondition.changeset(terms_and_condition, %{})

  def get_branch_location(user_id) do
    from(b in Branch, where: b.id == ^user_id, select: b.location)
    |> Repo.one()
  end

  def list_businesses, do: Repo.all(Business)

  def branch_service_data_query do
    from(bs in BranchService,
      join: b in Branch,
      on: bs.branch_id == b.id,
      join: cs in CountryService,
      on: bs.country_service_id == cs.id,
      join: s in Service,
      on: s.id == cs.service_id
    )
  end

  def branch_service_select(query) do
    query
    |> select([bs, b, cs, s], %{
      branch_service_id: bs.id,
      branch_id: bs.branch_id,
      country_service_id: cs.id,
      service_type_id: bs.service_type_id,
      service_id: s.id
    })
  end

  def group do
    s_types = ["walk_in", "on_demand", "walk_in", "walk_in", "on_demand", "home_service"]

    Enum.frequencies(s_types)
    |> Enum.map(fn {key, value} -> group_service_ids(key, value) end)
  end

  defp group_service_ids(key, value) do
    Enum.reduce(1..value, [], fn _, acc -> acc ++ [key] end)
  end

  def get_all_branch_service_data(bs_ids, branch_id) when is_list(bs_ids) do
    branch_service_data_query()
    |> where([bs, _, _, _], bs.id in ^bs_ids)
    |> where([_, b, _, _], b.id == ^branch_id)
    |> branch_service_select()
    |> Repo.all()
  end

  def get_all_branch_service_data(bs_id, branch_id) do
    branch_service_data_query()
    |> where([bs, _, _, _], bs.id == ^bs_id)
    |> where([_, b, _, _], b.id == ^branch_id)
    |> branch_service_select()
    |> Repo.one()
  end

  def get_business(id), do: Repo.get(Business, id)
  def get_business_by(params), do: Repo.get_by(Business, params)

  def get_business_by_user_id(id) do
    from(b in Business, where: b.user_id == ^id, preload: [:branches])
    |> Repo.all()
  end

  def get_branch_by_user_id(user_id) do
    from(b in Branch,
      join: bus in Business,
      on: b.business_id == bus.id,
      where: bus.user_id == ^user_id,
      where: b.status_id != "deleted",
      select: count(b.id)
    )
    |> Repo.one()
  end

  def get_business_with_branches(id) do
    from(b in Business, where: b.id == ^id, preload: [:branches])
    |> Repo.one()
  end

  def get_business_by_user_id_and_business_id(user_id, business_id) do
    from(b in Business, where: b.user_id == ^user_id and b.id == ^business_id)
    |> Repo.all()
  end

  def business_by_branch_base do
    Business
    |> join(:inner, [bus], b in Branch, on: b.business_id == bus.id)
  end

  def get_business_by_branch_id(ids) when is_list(ids) do
    business_by_branch_base()
    |> where([_, b], b.id in ^ids)
    |> Repo.all()
  end

  def get_business_by_branch_id(id) do
    business_by_branch_base()
    |> where([_, b], b.id == ^id)
    |> Repo.one()
  end

  def get_business_by_employee_id(employee_id) do
    from(bus in Business,
      join: b in Branch,
      on: b.business_id == bus.id,
      join: e in Employee,
      on: e.branch_id == b.id,
      where: e.id == ^employee_id
    )
    |> Repo.one()
  end

  def get_business_by_branch_service_id(branch_service_id) do
    from(bus in Business,
      join: b in Branch,
      on: b.business_id == bus.id,
      join: bs in BranchService,
      on: bs.branch_id == b.id,
      where: bs.id == ^branch_service_id
    )
    |> Repo.one()
  end

  def get_branch_by_employee_id(employee_id) do
    from(b in Branch, join: e in Employee, on: e.branch_id == b.id, where: e.id == ^employee_id)
    |> Repo.one()
  end

  def list_branches_by_branch_service(bs_ids) do
    from(b in Branch,
      join: bs in BranchService,
      on: bs.branch_id == b.id,
      where: bs.id in ^bs_ids,
      distinct: b.id
    )
    |> Repo.all()
  end

  def get_branch_by_branch_service(bs_id) do
    from(b in Branch, join: bs in BranchService, on: bs.branch_id == b.id, where: bs.id == ^bs_id)
    |> Repo.one()
  end

  def get_branch_by_job_id(job_id) do
    from(b in Branch,
      join: bs in BranchService,
      on: bs.branch_id == b.id,
      join: j in Job,
      on: bs.id == j.branch_service_id or bs.id in j.branch_service_ids,
      where: j.id == ^job_id,
      limit: 1
    )
    |> Repo.one()
  end

  def get_business_by_job_id(job_id) do
    from(j in Job,
      join: bs in BranchService,
      on: bs.id == j.branch_service_id or bs.id in j.branch_service_ids,
      join: b in Branch,
      on: bs.branch_id == b.id,
      join: bus in Business,
      on: bus.id == b.business_id,
      select: bus.user_id,
      where: j.id == ^job_id,
      limit: 1
    )
    |> Repo.one()
  end

  def get_branch_id_by_job_id(job_id) do
    from(b in Branch,
      join: e in Employee,
      on: e.branch_id == b.id,
      join: j in Job,
      on: e.id == j.employee_id,
      where: j.id == ^job_id,
      select: %{id: b.id}
    )
    |> Repo.one()
  end

  def get_branch_by_invoice_id(invoice_id) do
    from(b in Branch,
      join: bs in BranchService,
      on: bs.branch_id == b.id,
      join: j in Job,
      on: bs.id == j.branch_service_id,
      join: i in Invoice,
      on: j.id == i.job_id,
      where: i.id == ^invoice_id,
      distinct: b.id
    )
    |> Repo.one()
  end

  def get_branch_by_cash_payment_id(cp_id) do
    from(b in Branch,
      join: bs in BranchService,
      on: bs.branch_id == b.id,
      join: j in Job,
      on: bs.id == j.branch_service_id,
      join: i in Invoice,
      on: j.id == i.job_id,
      join: cp in CashPayment,
      on: cp.invoice_id == i.id,
      where: cp.id == ^cp_id,
      distinct: b.id
    )
    |> Repo.one()
  end

  def create_business(attrs \\ %{}) do
    %Business{}
    |> Business.changeset(attrs)
    |> Repo.insert()
  end

  def update_business(%Business{} = business, attrs) do
    business
    |> Business.changeset(attrs)
    |> Repo.update()
  end

  def delete_business(%Business{} = business), do: Repo.delete(business)

  def change_business(%Business{} = business), do: Business.changeset(business, %{})

  def list_branches, do: Repo.all(Branch)

  def list_branches_by(params) do
    make_query_for_getting_branches_for_admin(params)
    |> Scrivener.Paginater.paginate(get_config(params))
  end

  defp make_query_for_getting_branches_for_admin(params) do
    case params do
      %{search: search} ->
        from(b in Branch,
          order_by: [desc: b.inserted_at],
          where:
            fragment("? ilike ?", b.name, ^"%#{search}%") or
              fragment("? ilike ?", b.licence_no, ^"%#{search}%") or
              fragment("? ilike ?", b.phone, ^"%#{search}%") or
              fragment("? ilike ?", b.other_details, ^"%#{search}%")
        )

      _ ->
        from(b in Branch, order_by: [desc: b.inserted_at])
    end
  end

  def list_branches_by_ids(ids) do
    from(b in Branch, where: b.id in ^ids)
    |> Repo.all()
  end

  def get_branch!(id), do: Repo.get(Branch, id)

  def get_branch_by(id, name) do
    from(b in Branch, where: b.business_id == ^id and b.name == ^name)
    |> Repo.all()
  end

  def get_branch_by_business(business_id) do
    from(b in Branch, where: b.business_id == ^business_id and b.status_id != "deleted")
    |> Repo.all()
  end

  def get_branch_by_user(%{id: branch_id, user_id: user_id}) do
    from(b in Branch,
      join: bus in Business,
      on: b.business_id == bus.id,
      join: u in User,
      on: u.id == bus.user_id,
      where: b.id == ^branch_id and u.id == ^user_id
    )
    |> Repo.one()
  end

  def get_branch_services(branch_id, cs_ids) do
    from(bs in BranchService,
      #      join: cs in CountryService,
      where: bs.branch_id == ^branch_id and bs.country_service_id in ^cs_ids,
      group_by: bs.branch_id,
      select: fragment("array_agg(distinct ?)", bs.id)
    )
    |> Repo.all()
  end

  #  Get Branches by search

  defp get_branches_joins do
    from(b in Branch,
      join: bus in Business,
      on: bus.id == b.business_id,
      join: st in Setting,
      on: b.id == st.branch_id,
      join: u in User,
      on: u.id == bus.user_id,
      join: bs in BranchService,
      on: b.id == bs.branch_id,
      join: cs in CountryService,
      on: cs.id == bs.country_service_id,
      join: ss in ServiceSetting,
      on: ss.country_service_id == cs.id,
      join: s in Service,
      on: s.id == cs.service_id,
      join: c in Calendar,
      on: c.user_id == u.id
    )
  end

  defp get_branches_where(query, location, input) do
    query
    |> where(
      [b, bus, st, u, bs, cs, ss, s, c],
      #        s.id == ^input.service_id and
      st.type == "branch" and
        st.slug == "availability" and
        b.rating >= ^input.rating and
        b.status_id == "confirmed" and
        bus.user_id != ^input.user_id and
        (cs.country_id == ^input.country_id or cs.country_id == 1) and
        s.service_status_id == "active" and
        fragment("filter_zone(?,?)", b.zone_ids, ^location)
    )
    |> calculate_distance_clause(input[:location], input)
  end

  def calculate_distance_clause(query, location, %{distance: distance}) do
    query
    |> where(
      [b],
      fragment(
        "SELECT ST_DistanceSphere(
            ?,
            ST_SetSRID(ST_MakePoint(?, ?),4326)
            )/1000 <=  ?",
        b.location,
        ^location.long,
        ^location.lat,
        ^distance
      )
    )
  end

  def calculate_distance_clause(query, location, _input) do
    query
    |> where(
      [b, _, _, _, _, _, ss, _, _],
      fragment(
        "SELECT ST_DistanceSphere(
            ?,
            ST_SetSRID(ST_MakePoint(?, ?),4326)
            )/1000 <=  cast(?->> 'distance_limit' as int)",
        b.location,
        ^location.long,
        ^location.lat,
        ss.fields
      )
    )
  end

  defp select_for_multi_cs_ids(query) do
    query
    |> select(
      [b, bus, st, u, bs, cs, ss, s, c],
      %{
        fields: ss.fields,
        availability: st.fields,
        branch_location: b.location,
        branch_id: b.id,
        name: b.name,
        phone: b.phone,
        rating: b.rating,
        rating_count: b.rating_count,
        address: b.address,
        business_id: b.business_id,
        profile_pictures: b.profile_pictures,
        is_head_office: b.is_head_office,
        auto_assign: b.auto_assign,
        location: b.location,
        licence_no: b.licence_no,
        est_year: b.est_year,
        city_id: b.city_id,
        description: b.description,
        is_active: b.is_active,
        scheduled_jobs: c.schedule,
        geo: nil,
        service_name: s.name
      }
    )
  end

  defp select_for_single_cs_ids(query) do
    query
    |> select(
      [b, bus, st, u, bs, cs, ss, s, c],
      %{
        branch_location: b.location,
        fields: ss.fields,
        availability: st.fields,
        branch_id: b.id,
        name: b.name,
        phone: b.phone,
        rating: b.rating,
        rating_count: b.rating_count,
        address: b.address,
        business_id: b.business_id,
        profile_pictures: b.profile_pictures,
        scheduled_jobs: c.schedule,
        is_head_office: b.is_head_office,
        auto_assign: b.auto_assign,
        location: b.location,
        geo: nil,
        licence_no: b.licence_no,
        branch_service_id: bs.id,
        est_year: b.est_year,
        city_id: b.city_id,
        is_active: b.is_active,
        service_name: s.name,
        description: b.description
      }
    )
  end

  @doc """
    get_branches_by_search/1
    Gets Branches Data by Passing some search parameters

    TODO - Need to optimize this function by changing the Enum.map() into another query-based function.
  """

  def get_branches_by_search(%{service_ids: _, country_service_ids: cs_ids} = input) do
    location = CoreWeb.Utils.CommonFunctions.encode_location(input.location)

    query =
      get_branches_joins()
      |> get_branches_where(location, input)
      |> where(
        [_, _, _, _, _, _, _, s, _],
        s.id in ^input.service_ids
      )
      |> select_for_multi_cs_ids()

    query =
      case Core.Services.list_services_by_country_service(input.country_service_ids) do
        %{service_type_id: "on_demand"} ->
          case Core.Settings.get_tudo_setting_by(%{
                 slug: "max_ondemand_job_send_limit",
                 country_id: input.country_id
               }) do
            %{value: bsp_limit} ->
              from [...] in query,
                limit: ^if(is_float(bsp_limit), do: trunc(bsp_limit), else: bsp_limit)

            _ ->
              query
          end

        _ ->
          query
      end

    res = query |> Repo.all()

    Enum.map(res, fn r ->
      case get_branch_services(r.branch_id, cs_ids) do
        [] -> []
        [branch_service_ids] -> Map.merge(r, %{branch_service_ids: branch_service_ids})
      end
    end)
    |> List.flatten()
  end

  # for single cs_id
  def get_branches_by_search(input) do
    location = CoreWeb.Utils.CommonFunctions.encode_location(input.location)

    query =
      get_branches_joins()
      |> get_branches_where(location, input)
      |> where(
        [_, _, _, _, _, _, _, s, _],
        s.id == ^input.service_id
      )
      |> select_for_single_cs_ids()

    # query will chanage for country_service_id
    # will do in  get_service_by_country_service for country_service_ids
    # merge get_tudo_setting_by into get_service_by_country_service query and return %{value: bsp_limit}
    query =
      case Core.Services.get_service_by_country_service(input.country_service_id) do
        %{service_type_id: "on_demand"} ->
          case Core.Settings.get_tudo_setting_by(%{
                 slug: "max_ondemand_job_send_limit",
                 country_id: input.country_id
               }) do
            %{value: bsp_limit} ->
              from [...] in query,
                limit: ^if(is_float(bsp_limit), do: trunc(bsp_limit), else: bsp_limit)

            _ ->
              query
          end

        _ ->
          query
      end

    query |> Repo.all()
  end

  defp branch_query do
    from(b in Branch,
      join: bus in Business,
      on: bus.id == b.business_id,
      join: st in Setting,
      on: b.id == st.branch_id,
      join: u in User,
      on: u.id == bus.user_id,
      join: bs in BranchService,
      on: b.id == bs.branch_id,
      join: cs in CountryService,
      on: cs.id == bs.country_service_id,
      join: ss in ServiceSetting,
      on: ss.country_service_id == cs.id,
      join: s in Service,
      on: s.id == cs.service_id,
      join: c in Calendar,
      on: c.user_id == u.id
    )
  end

  def get_branch_by_search(%{service_ids: _, country_service_ids: _} = input) do
    location = Geo.WKB.encode!(input.location_dest)

    branch_query()
    |> by_search_where(input, location)
    |> by_search_select()
    |> Repo.all()
  end

  @doc """
  get_branch_by_search
    Query To get_branch_by_search

  [Quick View Of This Function]
  -> Query To get_branch_by_search
  -! Following Line Might be used in the future
  -! and fragment("filter_scheduled_jobs(?,?,?,?)",c.schedule,^input.arrive_at,^input.expected_work_duration, ss.fields),
  """
  def get_branch_by_search(input) do
    location = Geo.WKB.encode!(input.location_dest)

    branch_query()
    |> by_search_where(input, location)
    |> by_search_select()
    |> Repo.all()
  end

  defp by_search_where(query, %{service_ids: ids, branch_ids: branch_ids} = input, location) do
    query
    |> where(
      [b, _, st, _, _, _, ss, s],
      b.id in ^branch_ids and
        s.id in ^ids and
        st.type == "branch" and
        b.status_id == "confirmed" and
        st.slug == "availability" and
        fragment("calculate_distance(?,?,?,?)", b.location, ^location, ss.fields, ^input)
    )
  end

  defp by_search_where(query, %{service_ids: ids} = input, location) do
    query
    |> where(
      [b, _, st, _, _, _, ss, s],
      b.id == ^input.branch_id and
        s.id in ^ids and
        st.type == "branch" and
        b.status_id == "confirmed" and
        st.slug == "availability" and
        fragment("calculate_distance(?,?,?,?)", b.location, ^location, ss.fields, ^input)
    )
  end

  defp by_search_where(query, input, location) do
    query
    |> where(
      [b, _, st, _, _, _, ss, s],
      b.id == ^input.branch_id and
        s.id == ^input.service_id and
        st.type == "branch" and
        b.status_id == "confirmed" and
        st.slug == "availability" and
        fragment("calculate_distance(?,?,?,?)", b.location, ^location, ss.fields, ^input)
    )
  end

  defp by_search_select(query) do
    query
    |> select([b, bus, st, _, _, _, _, _, c], %{
      availability: st.fields,
      branch_id: b.id,
      scheduled_jobs: c.schedule
    })
  end

  @doc """
  get_branches_for_prospects
    generate query and fetch branches for prospects

  [Quick View Of This Function]
  -> fetch branches for prospects
  -! the following might be used in the future
  -! and fragment("calculate_distance(?,?,?,?)", b.location, ^location, ss.fields, ^input)
  -! and fragment("is_available_for_arrive_at(?,?)",st.fields,^input.arrive_at)
  -! and fragment("filter_scheduled_jobs(?,?,?,?)",c.schedule,^input.arrive_at,^input.expected_work_duration, ss.fields)
  """
  def get_branches_for_prospects(input, used_for \\ :lead) do
    location =
      if is_struct(input.location),
        do: Geo.WKB.encode!(input.location),
        else: CommonFunctions.encode_location(input.location)

    branch_query()
    |> prospects_where(input, location)
    |> prospects_distinct()
    |> prospects_select(used_for)
    |> Repo.all()
  end

  defp prospects_where(query, input, location) do
    cs_ids =
      if Map.get(input, :country_service_id) do
        [input.country_service_id]
      else
        input.country_service_ids
      end

    query
    |> where(
      [b, bus, _, _, _, cs],
      cs.id in ^cs_ids and
        bus.user_id != ^input.user_id and b.status_id == "confirmed" and
        fragment("filter_zone(?,?)", b.zone_ids, ^location)
    )
  end

  defp prospects_distinct(query), do: query |> distinct([b], b.id)

  defp prospects_select(query, :lead) do
    query
    |> select([b, _, st, _, _, _, _, _, c], %{
      availability: st.fields,
      branch_id: b.id,
      scheduled_jobs: c.schedule
    })
  end

  defp prospects_select(query, :bid) do
    query
    |> select([b, _, st, _, _, _, _, _, c], %{
      branch_id: b.id,
      location: b.location
    })
  end

  def get_branches_for_leads(input) do
    branches_for_leads_joins()
    |> branches_for_leads_where(input)
    |> distinct([b], b.id)
    |> select([b], %{branch_id: b.id, location: b.location})
    |> Repo.all()
  end

  def branches_for_leads_joins() do
    from b in Branch,
      join: bus in Business,
      on: bus.id == b.business_id,
      join: u in User,
      on: u.id == bus.user_id,
      join: bs in BranchService,
      on: b.id == bs.branch_id,
      join: cs in CountryService,
      on: cs.id == bs.country_service_id,
      join: ss in ServiceSetting,
      on: ss.country_service_id == cs.id
  end

  def branches_for_leads_where(query, input) do
    location =
      if is_struct(input.location) do
        Geo.WKB.encode!(input.location)
      else
        CoreWeb.Utils.CommonFunctions.encode_location(input.location)
      end

    query
    |> where([b, bus], bus.user_id != ^input.user_id)
    |> where([b], b.status_id == "confirmed")
    |> where([b], fragment("filter_zone(?,?)", b.zone_ids, ^location))
    |> calculate_distance_clause_for_leads(input[:location], input)
  end

  def calculate_distance_clause_for_leads(query, location, %{distance: distance}) do
    %Geo.Point{coordinates: {long, lat}} = location

    query
    |> where(
      [b],
      fragment(
        "SELECT ST_DistanceSphere(
            ?,
            ST_SetSRID(ST_MakePoint(?, ?),4326)
            )/1000 <=  ?",
        b.location,
        ^long,
        ^lat,
        ^distance
      )
    )
  end

  def calculate_distance_clause_for_leads(query, location, _input) do
    %Geo.Point{coordinates: {long, lat}} = location

    query
    |> where(
      [b, ..., ss],
      fragment(
        "SELECT ST_DistanceSphere(
            ?,
            ST_SetSRID(ST_MakePoint(?, ?),4326)
            )/1000 <=  cast(?->> 'distance_limit' as int) ",
        b.location,
        ^long,
        ^lat,
        ss.fields
      )
    )
  end

  def create_branch(attrs \\ %{}) do
    %Branch{}
    |> Branch.changeset(attrs)
    |> Repo.insert()
  end

  def update_branch(%Branch{} = branch, attrs) do
    branch
    |> Branch.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_branch(%Branch{} = branch), do: Repo.delete(branch)

  def change_branch(%Branch{} = branch), do: Branch.changeset(branch, %{})

  def list_dropdowns, do: Repo.all(Dropdown)

  def get_dropdown_by_user_id(type, country_id) do
    from(b in Dropdown,
      distinct: [desc: b.slug],
      where: b.type == ^type and (b.country_id == ^country_id or b.country_id == 1)
    )
    |> Repo.all()
  end

  def get_dropdown_by_user_id(type) do
    from(b in Dropdown, where: b.type == ^type)
    |> Repo.all()
  end

  def get_dropdown!(id), do: Repo.get!(Dropdown, id)
  def get_dropdown(id), do: Repo.get(Dropdown, id)

  def create_dropdown(attrs \\ %{}) do
    %Dropdown{}
    |> Dropdown.changeset(attrs)
    |> Repo.insert()
  end

  def update_dropdown(%Dropdown{} = dropdown, attrs) do
    dropdown
    |> Dropdown.changeset(attrs)
    |> Repo.update()
  end

  def delete_dropdown(%Dropdown{} = dropdown), do: Repo.delete(dropdown)

  def change_dropdown(%Dropdown{} = dropdown), do: Dropdown.changeset(dropdown, %{})
end
