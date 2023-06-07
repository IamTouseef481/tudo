defmodule Core.Services do
  @moduledoc """
  The Services context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{
    BranchService,
    CountryService,
    EmployeeService,
    Service,
    ServiceGroup,
    ServiceSetting,
    ServiceStatus,
    ServiceType
  }

  @doc """
  Returns the list of services.

  ## Examples

      iex> list_services()
      [%Service{}, ...]

  """
  def list_services do
    #    pagination_params = CoreWeb.Utils.Paginator.make_pagination_params()
    #    Service
    #    |> Scrivener.Paginater.paginate(pagination_params)
    Service
    #    from(s in Service, where: s.service_status_id == "active")
    |> Repo.all()
  end

  @doc """
  Gets a single service.

  Raises `Ecto.NoResultsError` if the Service does not exist.

  ## Examples

      iex> get_service!(123)
      %Service{}

      iex> get_service!(456)
      ** (Ecto.NoResultsError)

  """
  def get_service!(id), do: Repo.get!(Service, id)

  def get_service(ids) when is_list(ids),
    do: from(s in Service, where: s.id in ^ids) |> Repo.all()

  def get_service(id), do: Repo.get(Service, id)

  def get_service_by(params), do: Repo.get_by(Service, params)

  def list_services_by_branch_service(branch_service_ids) do
    from(s in Service,
      join: cs in CountryService,
      on: cs.service_id == s.id,
      join: bs in BranchService,
      on: bs.country_service_id == cs.id,
      where: bs.id in ^branch_service_ids and cs.is_active
    )
    |> Repo.all()
  end

  def get_service_by_branch_service(branch_service_id) do
    from(s in Service,
      join: cs in CountryService,
      on: cs.service_id == s.id,
      join: bs in BranchService,
      on: bs.country_service_id == cs.id,
      where: bs.id == ^branch_service_id and cs.is_active
    )
    |> Repo.one()
  end

  def get_service_ids_by_country_service_ids(country_service_ids) do
    from(cs in CountryService,
      where: cs.id in ^country_service_ids and cs.is_active,
      select: cs.service_id
    )
    |> Repo.all()
  end

  def get_service_and_branch_name_by_branch_service(branch_service_id) do
    from(s in Service,
      join: cs in CountryService,
      on: cs.service_id == s.id,
      join: bs in BranchService,
      on: bs.country_service_id == cs.id,
      join: b in Core.Schemas.Branch,
      on: bs.branch_id == b.id,
      where: bs.id == ^branch_service_id and cs.is_active,
      select: %{name: s.name, bsp_name: b.name}
    )
    |> Repo.one()
  end

  def get_service_by_country_service(country_service_id) do
    from(s in Service,
      join: cs in CountryService,
      on: cs.service_id == s.id,
      where: cs.id == ^country_service_id and cs.is_active and s.service_status_id == "active"
    )
    |> Repo.one()
  end

  def list_services_by_country_service(country_service_ids) when is_list(country_service_ids) do
    from(s in Service,
      join: cs in CountryService,
      on: cs.service_id == s.id,
      where: cs.id in ^country_service_ids and cs.is_active and s.service_status_id == "active"
    )
    |> Repo.all()
  end

  def list_services_by_country_service(cs_id),
    do: get_service_by_country_service(cs_id)

  def get_country_service_by_country_ids_and_service_id(%{
        country_ids: country_service_ids,
        service_id: service_id
      }) do
    query =
      from c in CountryService,
        where: c.country_id == ^country_service_ids and c.service_id == ^service_id

    Repo.all(query)
  end

  @doc """
  Creates a service.

  ## Examples

      iex> create_service(%{field: value})
      {:ok, %Service{}}

      iex> create_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service(attrs \\ %{}) do
    %Service{}
    |> Service.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a service.

  ## Examples

      iex> update_service(service, %{field: new_value})
      {:ok, %Service{}}

      iex> update_service(service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service(%Service{} = service, attrs) do
    service
    |> Service.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Service.

  ## Examples

      iex> delete_service(service)
      {:ok, %Service{}}

      iex> delete_service(service)
      {:error, %Ecto.Changeset{}}

  """
  def delete_service(%Service{} = service) do
    Repo.delete(service)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service changes.

  ## Examples

      iex> change_service(service)
      %Ecto.Changeset{source: %Service{}}

  """
  def change_service(%Service{} = service) do
    Service.changeset(service, %{})
  end

  @doc """
  Returns the list of service_groups.

  ## Examples

      iex> list_service_groups()
      [%ServiceGroup{}, ...]

  """
  def list_service_groups do
    ServiceGroup
    |> order_by([sg], asc: sg.name)
    |> Repo.all()
  end

  @doc """
  Gets a single service_group.

  Raises `Ecto.NoResultsError` if the Service group does not exist.

  ## Examples

      iex> get_service_group!(123)
      %ServiceGroup{}

      iex> get_service_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_service_group!(id), do: Repo.get!(ServiceGroup, id)
  def getting_service_group(id), do: Repo.get(ServiceGroup, id)
  def get_service_group(params), do: Repo.get_by(ServiceGroup, params)

  def get_service_group_by do
    ServiceGroup
    |> where(is_active: true)
    |> order_by([sg], asc: sg.name)
    |> Repo.all()
  end

  def get_service_group_by_service(service_id) do
    from(sg in ServiceGroup,
      join: s in Service,
      on: s.service_group_id == sg.id,
      where: s.id == ^service_id and s.service_status_id == "active" and sg.is_active
    )
    |> Repo.all()
  end

  @doc """
  Creates a service_group.

  ## Examples

      iex> create_service_group(%{field: value})
      {:ok, %ServiceGroup{}}

      iex> create_service_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service_group(attrs \\ %{}) do
    %ServiceGroup{}
    |> ServiceGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a service_group.

  ## Examples

      iex> update_service_group(service_group, %{field: new_value})
      {:ok, %ServiceGroup{}}

      iex> update_service_group(service_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service_group(%ServiceGroup{} = service_group, attrs) do
    service_group
    |> ServiceGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ServiceGroup.

  ## Examples

      iex> delete_service_group(service_group)
      {:ok, %ServiceGroup{}}

      iex> delete_service_group(service_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_service_group(%ServiceGroup{} = service_group) do
    Repo.delete(service_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service_group changes.

  ## Examples

      iex> change_service_group(service_group)
      %Ecto.Changeset{source: %ServiceGroup{}}

  """
  def change_service_group(%ServiceGroup{} = service_group) do
    ServiceGroup.changeset(service_group, %{})
  end

  @doc """
  Returns the list of country_services.

  ## Examples

      iex> list_country_services()
      [%CountryService{}, ...]

  """
  def list_country_services do
    pagination_params = CoreWeb.Utils.Paginator.make_pagination_params()

    CountryService
    |> Scrivener.Paginater.paginate(pagination_params)

    #    Repo.all(CountryService)
  end

  def list_country_services(ids) do
    from(cs in CountryService)
    |> where([cs], cs.service_id in ^ids and cs.is_active)
    |> preload([:service])
    |> Repo.all()
  end

  @doc """
  Gets a single country_service.

  Raises `Ecto.NoResultsError` if the Country service does not exist.

  ## Examples

      iex> get_country_service!(123)
      %CountryService{}

      iex> get_country_service!(456)
      ** (Ecto.NoResultsError)

  """
  def get_country_service(id), do: Repo.get(CountryService, id)

  def list_services_ids_by_cs_ids(ids) do
    from(cs in CountryService,
      where: cs.id in ^ids,
      select: cs.service_id
    )
    |> Repo.all()
  end

  def get_country_services_by_ids(ids) when is_list(ids) do
    from(cs in CountryService,
      where: cs.id in ^ids
    )
    |> Repo.all()
  end

  def get_country_services_by_ids(_), do: []

  def list_active_country_service_ids(id) when is_list(id) do
    from(cs in CountryService,
      where: cs.id in ^id and cs.is_active,
      select: cs.service_id
    )
    |> Repo.all()
  end

  def list_active_country_service_ids(id),
    do: get_active_country_service(id)

  def get_active_country_service(id) do
    from(cs in CountryService, where: cs.id == ^id and cs.is_active)
    |> Repo.one()
  end

  def get_services_by_country_id(id) do
    from(cs in CountryService, where: cs.country_id == ^id and cs.is_active)
    |> Repo.all()
  end

  def get_country_service_by_country_and_service_id(%{
        country_id: country_id,
        service_id: service_id
      }) do
    from(cs in CountryService,
      where:
        cs.service_id == ^service_id and (cs.country_id == ^country_id or cs.country_id == 1) and
          cs.is_active
    )
    |> Repo.all()
  end

  def get_country_service_by_country_and_service(%{country_id: country_id, service_id: service_id}) do
    from(cs in CountryService,
      where: cs.service_id == ^service_id and (cs.country_id == ^country_id or cs.country_id == 1)
    )
    |> Repo.all()
  end

  def get_service_ids_by_country_id(country_id) do
    from(cs in CountryService,
      where: (cs.country_id == ^country_id or cs.country_id == 1) and cs.is_active,
      distinct: cs.service_id,
      order_by: [desc: cs.country_id],
      select: cs.service_id
    )
    |> Repo.all()
  end

  def get_country_service_ids_by_country_id(country_id) do
    from(cs in CountryService,
      where: (cs.country_id == ^country_id or cs.country_id == 1) and cs.is_active,
      distinct: cs.service_id,
      order_by: [desc: cs.country_id],
      select: cs.id
    )
    |> Repo.all()
  end

  def get_country_services_by_branch_id(branch_id) do
    from(bs in BranchService,
      where: bs.branch_id == ^branch_id and bs.is_active,
      select: bs.country_service_id
    )
    |> Repo.all()
  end

  def get_services_by_branch_id(branch_id) do
    from(s in Service,
      join: cs in CountryService,
      on: s.id == cs.service_id,
      join: bs in BranchService,
      on: cs.id == bs.country_service_id,
      where:
        bs.branch_id == ^branch_id and bs.is_active and cs.is_active and
          s.service_status_id == "active",
      select: s.id
    )
    |> Repo.all()
  end

  @doc """
  Creates a country_service.

  ## Examples

      iex> create_country_service(%{field: value})
      {:ok, %CountryService{}}

      iex> create_country_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_country_service(attrs \\ %{}) do
    %CountryService{}
    |> CountryService.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a country_service.

  ## Examples

      iex> update_country_service(country_service, %{field: new_value})
      {:ok, %CountryService{}}

      iex> update_country_service(country_service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_country_service(%CountryService{} = country_service, attrs) do
    country_service
    |> CountryService.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CountryService.

  ## Examples

      iex> delete_country_service(country_service)
      {:ok, %CountryService{}}

      iex> delete_country_service(country_service)
      {:error, %Ecto.Changeset{}}

  """
  def delete_country_service(%CountryService{} = country_service) do
    Repo.delete(country_service)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking country_service changes.

  ## Examples

      iex> change_country_service(country_service)
      %Ecto.Changeset{source: %CountryService{}}

  """
  def change_country_service(%CountryService{} = country_service) do
    CountryService.changeset(country_service, %{})
  end

  @doc """
  Returns the list of branch_services.

  ## Examples

      iex> list_branch_services()
      [%BranchService{}, ...]

  """
  def list_branch_services(ids) when is_list(ids),
    do: from(bs in BranchService) |> where([bs], bs.id in ^ids) |> Repo.all()

  def list_service_type_ids_and_country_service_ids(ids) do
    BranchService
    |> list_service_type_where(ids)
    |> select([bs], %{
      service_type_id: bs.service_type_id,
      country_service_id: bs.country_service_id
    })
    |> Repo.all()
  end

  def list_service_type_ids_by_branch_service(ids) do
    BranchService
    |> list_service_type_where(ids)
    |> select([bs], bs.service_type_id)
    |> distinct([bs], bs.service_type_id)
    |> Repo.all()
  end

  defp list_service_type_where(query, ids), do: query |> where([bs], bs.id in ^ids)

  def list_branch_services do
    pagination_params = CoreWeb.Utils.Paginator.make_pagination_params()

    BranchService
    |> Scrivener.Paginater.paginate(pagination_params)

    #    Repo.all(BranchService)
  end

  @doc """
  Gets a single branch_service.

  Raises `Ecto.NoResultsError` if the Branch service does not exist.

  ## Examples

      iex> get_branch_service!(123)
      %BranchService{}

      iex> get_branch_service!(456)
      ** (Ecto.NoResultsError)

  """
  def get_branch_service(ids) when is_list(ids),
    do: from(bs in BranchService, where: bs.id in ^ids) |> Repo.all()

  def get_branch_service(id), do: Repo.get(BranchService, id)

  def get_branch_service_by(params), do: Repo.get_by(BranchService, params)

  def get_branch_services_by_branch_id(branch_id, country_service_id) do
    from(bs in BranchService,
      where:
        bs.branch_id == ^branch_id and bs.country_service_id == ^country_service_id and
          bs.is_active
    )
    |> Repo.all()
  end

  def get_branch_services_by(%{
        branch_id: branch_id,
        country_service_id: country_service_id,
        service_type_id: service_type_id
      }) do
    from(bs in BranchService,
      where:
        bs.branch_id == ^branch_id and bs.country_service_id == ^country_service_id and
          bs.service_type_id == ^service_type_id
    )
    |> Repo.all()
  end

  def get_branch_services_by_service_type(%{service_type_id: service_type_id}) do
    from(bs in BranchService,
      where: bs.service_type_id == ^service_type_id and bs.is_active
    )
    |> Repo.all()
  end

  def get_branch_services_by_branch(branch_id) do
    from(bs in BranchService,
      where: bs.branch_id == ^branch_id and bs.is_active
    )
    |> Repo.all()
  end

  def get_branch_services_by_branch_id(%{branch_id: branch_id, service_ids: service_ids}) do
    from(s in Service,
      join: cs in CountryService,
      on: s.id == cs.service_id,
      join: bs in BranchService,
      on: cs.id == bs.country_service_id,
      where:
        bs.branch_id == ^branch_id and s.id in ^service_ids and cs.is_active and bs.is_active,
      select: bs.id
    )
    |> Repo.all()
  end

  def get_active_services_by_branch(branch_id) do
    from(s in Service,
      join: cs in CountryService,
      on: s.id == cs.service_id,
      join: bs in BranchService,
      on: cs.id == bs.country_service_id,
      where: bs.branch_id == ^branch_id and bs.is_active,
      select: %{
        id: s.id,
        name: s.name,
        service_group_id: s.service_group_id,
        branch_service_id: bs.id,
        country_service_id: cs.id,
        service_type_id: s.service_type_id
      }
    )
    |> Repo.all()
  end

  def get_active_services_by_branch_for_invite_employee_socket(branch_id) do
    from(s in Service,
      join: cs in CountryService,
      on: s.id == cs.service_id,
      join: bs in BranchService,
      on: cs.id == bs.country_service_id,
      where: bs.branch_id == ^branch_id and bs.is_active,
      select: %{
        id: s.id,
        name: s.name,
        service_group_id: s.service_group_id,
        branch_service_id: bs.id,
        country_service_id: cs.id,
        service_type_id: s.service_type_id,
        country_service: %Ecto.Association.NotLoaded{}
      }
    )
    #    %{service: %{service_type: %{}, service_group: %{}, service_status: %{}}
    |> Repo.all()
  end

  def get_branch_by_branch_service_id(branch_service_id) do
    from(bs in BranchService, join: b in Core.Schemas.Branch, on: b.id == bs.branch_id)
    |> where_clause(branch_service_id)
    |> query_select()
    |> Repo.all()
  end

  defp where_clause(query, id) when is_list(id), do: query |> where([bs, _], bs.id in ^id)

  defp where_clause(query, id), do: query |> where([bs, _], bs.id == ^id)

  defp query_select(query),
    do: query |> select([_, b], %{branch_id: b.id, auto_assign: b.auto_assign})

  @doc """
  Creates a branch_service.

  ## Examples

      iex> create_branch_service(%{field: value})
      {:ok, %BranchService{}}

      iex> create_branch_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_branch_service(attrs \\ %{}) do
    %BranchService{}
    |> BranchService.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a branch_service.

  ## Examples

      iex> update_branch_service(branch_service, %{field: new_value})
      {:ok, %BranchService{}}

      iex> update_branch_service(branch_service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_branch_service(%BranchService{} = branch_service, attrs) do
    branch_service
    |> BranchService.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BranchService.

  ## Examples

      iex> delete_branch_service(branch_service)
      {:ok, %BranchService{}}

      iex> delete_branch_service(branch_service)
      {:error, %Ecto.Changeset{}}

  """
  def delete_branch_service(%BranchService{} = branch_service) do
    Repo.delete(branch_service)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking branch_service changes.

  ## Examples

      iex> change_branch_service(branch_service)
      %Ecto.Changeset{source: %BranchService{}}

  """
  def change_branch_service(%BranchService{} = branch_service) do
    BranchService.changeset(branch_service, %{})
  end

  @doc """
  Returns the list of employee_services.

  ## Examples

      iex> list_employee_services()
      [%EmployeeService{}, ...]

  """
  def list_employee_services do
    Repo.all(EmployeeService)
  end

  @doc """
  Gets a single employee_service.

  Raises `Ecto.NoResultsError` if the Employee service does not exist.

  ## Examples

      iex> get_employee_service!(123)
      %EmployeeService{}

      iex> get_employee_service!(456)
      ** (Ecto.NoResultsError)

  """
  def get_employee_service!(id), do: Repo.get!(EmployeeService, id)
  def get_employee_service(id), do: Repo.get(EmployeeService, id)

  def get_employee_service_by(branch_service_id, employee_id) do
    from(b in EmployeeService,
      where: b.employee_id == ^employee_id and b.branch_service_id == ^branch_service_id
    )
    |> Repo.all()
  end

  def get_employee_service_by_id(id) do
    from(b in EmployeeService, where: b.id == ^id)
    |> Repo.all()
  end

  def get_employee_services_by_branch_service_id(input) do
    branch_service_id = input[:branch_service_id] || input[:branch_service_ids]

    from(es in EmployeeService)
    |> where_clause_for_employee(branch_service_id)
    |> district_clause
    |> Repo.all()
  end

  defp where_clause_for_employee(query, ids) when is_list(ids),
    do: query |> where([es], es.branch_service_id in ^ids)

  defp where_clause_for_employee(query, id), do: query |> where([es], es.branch_service_id == ^id)

  defp district_clause(query), do: query |> distinct([es], es.employee_id)

  @doc """
  Creates a employee_service.

  ## Examples

      iex> create_employee_service(%{field: value})
      {:ok, %EmployeeService{}}

      iex> create_employee_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_employee_service(attrs \\ %{}) do
    %EmployeeService{}
    |> EmployeeService.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a employee_service.

  ## Examples

      iex> update_employee_service(employee_service, %{field: new_value})
      {:ok, %EmployeeService{}}

      iex> update_employee_service(employee_service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_employee_service(%EmployeeService{} = employee_service, attrs) do
    employee_service
    |> EmployeeService.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a EmployeeService.

  ## Examples

      iex> delete_employee_service(employee_service)
      {:ok, %EmployeeService{}}

      iex> delete_employee_service(employee_service)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employee_service(%EmployeeService{} = employee_service) do
    Repo.delete(employee_service)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking employee_service changes.

  ## Examples

      iex> change_employee_service(employee_service)
      %Ecto.Changeset{source: %EmployeeService{}}

  """
  def change_employee_service(%EmployeeService{} = employee_service) do
    EmployeeService.changeset(employee_service, %{})
  end

  @doc """
  Returns the list of service_types.

  ## Examples

      iex> list_service_types()
      [%ServiceType{}, ...]

  """
  def list_service_types do
    Repo.all(ServiceType)
  end

  def list_service_types(ids) do
    from(st in ServiceType)
    |> where([st], st.id in ^ids)
    |> Repo.all()
  end

  @doc """
  Gets a single service_type.

  Raises `Ecto.NoResultsError` if the Service type does not exist.

  ## Examples

      iex> get_service_type!(123)
      %ServiceType{}

      iex> get_service_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_service_type!(id), do: Repo.get!(ServiceType, id)

  def get_service_type(ids) when is_list(ids),
    do: ServiceType |> where([st], st.id in ^ids) |> Repo.all()

  def get_service_type(id), do: Repo.get(ServiceType, id)

  def make_services_grouped(services) do
    with grouped_services <- Enum.group_by(services, & &1.service_group_id),
         service_groups <- list_service_groups(),
         service_groups <-
           service_groups
           |> Enum.map(&%{service_group_name: &1.name, grouped_services: grouped_services[&1.id]}) do
      service_groups
      |> Enum.filter(&(&1.grouped_services != nil))
    end
  end

  @doc """
  Creates a service_type.

  ## Examples

      iex> create_service_type(%{field: value})
      {:ok, %ServiceType{}}

      iex> create_service_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service_type(attrs \\ %{}) do
    %ServiceType{}
    |> ServiceType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a service_type.

  ## Examples

      iex> update_service_type(service_type, %{field: new_value})
      {:ok, %ServiceType{}}

      iex> update_service_type(service_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service_type(%ServiceType{} = service_type, attrs) do
    service_type
    |> ServiceType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ServiceType.

  ## Examples

      iex> delete_service_type(service_type)
      {:ok, %ServiceType{}}

      iex> delete_service_type(service_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_service_type(%ServiceType{} = service_type) do
    Repo.delete(service_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service_type changes.

  ## Examples

      iex> change_service_type(service_type)
      %Ecto.Changeset{source: %ServiceType{}}

  """
  def change_service_type(%ServiceType{} = service_type) do
    ServiceType.changeset(service_type, %{})
  end

  @doc """
  Returns the list of service_statuses.

  ## Examples

      iex> list_service_statuses()
      [%ServiceStatus{}, ...]

  """
  def list_service_statuses do
    Repo.all(ServiceStatus)
  end

  @doc """
  Gets a single service_status.

  Raises `Ecto.NoResultsError` if the Service status does not exist.

  ## Examples

      iex> get_service_status!(123)
      %ServiceStatus{}

      iex> get_service_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_service_status!(id), do: Repo.get!(ServiceStatus, id)
  def get_service_status(id), do: Repo.get(ServiceStatus, id)

  @doc """
  Creates a service_status.

  ## Examples

      iex> create_service_status(%{field: value})
      {:ok, %ServiceStatus{}}

      iex> create_service_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service_status(attrs \\ %{}) do
    %ServiceStatus{}
    |> ServiceStatus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a service_status.

  ## Examples

      iex> update_service_status(service_status, %{field: new_value})
      {:ok, %ServiceStatus{}}

      iex> update_service_status(service_status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service_status(%ServiceStatus{} = service_status, attrs) do
    service_status
    |> ServiceStatus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ServiceStatus.

  ## Examples

      iex> delete_service_status(service_status)
      {:ok, %ServiceStatus{}}

      iex> delete_service_status(service_status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_service_status(%ServiceStatus{} = service_status) do
    Repo.delete(service_status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service_status changes.

  ## Examples

      iex> change_service_status(service_status)
      %Ecto.Changeset{source: %ServiceStatus{}}

  """
  def change_service_status(%ServiceStatus{} = service_status) do
    ServiceStatus.changeset(service_status, %{})
  end

  @doc """
  Returns the list of service_settings.

  ## Examples

      iex> list_service_settings()
      [%ServiceSetting{}, ...]

  """
  def list_service_settings do
    Repo.all(ServiceSetting)
  end

  @doc """
  Gets a single service_setting.

  Raises `Ecto.NoResultsError` if the Service setting does not exist.

  ## Examples

      iex> get_service_setting!(123)
      %ServiceSetting{}

      iex> get_service_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_service_setting!(id), do: Repo.get!(ServiceSetting, id)

  def get_service_setting_by_country_service_id(id) do
    from(ss in ServiceSetting, where: ss.country_service_id == ^id)
    |> Repo.all()
  end

  @doc """
  Creates a service_setting.

  ## Examples

      iex> create_service_setting(%{field: value})
      {:ok, %ServiceSetting{}}

      iex> create_service_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service_setting(attrs \\ %{}) do
    %ServiceSetting{}
    |> ServiceSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a service_setting.

  ## Examples

      iex> update_service_setting(service_setting, %{field: new_value})
      {:ok, %ServiceSetting{}}

      iex> update_service_setting(service_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service_setting(%ServiceSetting{} = service_setting, attrs) do
    service_setting
    |> ServiceSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ServiceSetting.

  ## Examples

      iex> delete_service_setting(service_setting)
      {:ok, %ServiceSetting{}}

      iex> delete_service_setting(service_setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_service_setting(%ServiceSetting{} = service_setting) do
    Repo.delete(service_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service_setting changes.

  ## Examples

      iex> change_service_setting(service_setting)
      %Ecto.Changeset{source: %ServiceSetting{}}

  """
  def change_service_setting(%ServiceSetting{} = service_setting) do
    ServiceSetting.changeset(service_setting, %{})
  end
end
