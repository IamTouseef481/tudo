defmodule Core.Regions do
  @moduledoc """
  The Regions context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{Cities, Continents, Countries, Languages, States, Unit}

  @doc """
  Returns the list of continents.

  ## Examples

      iex> list_continents()
      [%Continents{}, ...]

  """
  def list_continents do
    Repo.all(Continents)
  end

  @doc """
  Gets a single continents.

  Raises `Ecto.NoResultsError` if the Continents does not exist.

  ## Examples

      iex> get_continents!(123)
      %Continents{}

      iex> get_continents!(456)
      ** (Ecto.NoResultsError)

  """
  def get_continents!(id), do: Repo.get!(Continents, id)
  def get_continents(id), do: Repo.get(Continents, id)

  @doc """
  Creates a continents.

  ## Examples

      iex> create_continents(%{field: value})
      {:ok, %Continents{}}

      iex> create_continents(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_continents(attrs \\ %{}) do
    %Continents{}
    |> Continents.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a continents.

  ## Examples

      iex> update_continents(continents, %{field: new_value})
      {:ok, %Continents{}}

      iex> update_continents(continents, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_continents(%Continents{} = continents, attrs) do
    continents
    |> Continents.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Continents.

  ## Examples

      iex> delete_continents(continents)
      {:ok, %Continents{}}

      iex> delete_continents(continents)
      {:error, %Ecto.Changeset{}}

  """
  def delete_continents(%Continents{} = continents) do
    Repo.delete(continents)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking continents changes.

  ## Examples

      iex> change_continents(continents)
      %Ecto.Changeset{source: %Continents{}}

  """
  def change_continents(%Continents{} = continents) do
    Continents.changeset(continents, %{})
  end

  @doc """
  Returns the list of countries.

  ## Examples

      iex> list_countries()
      [%Countries{}, ...]

  """
  def list_countries do
    pagination_params = CoreWeb.Utils.Paginator.make_pagination_params()

    Countries
    |> Scrivener.Paginater.paginate(pagination_params)

    #    Repo.all(Countries)
  end

  @doc """
  Gets a single countries.

  Raises `Ecto.NoResultsError` if the Countries does not exist.

  ## Examples

      iex> get_countries!(123)
      %Countries{}

      iex> get_countries!(456)
      ** (Ecto.NoResultsError)

  """
  def get_countries!(id), do: Repo.get!(Countries, id)
  def get_countries(id), do: Repo.get(Countries, id)

  def get_country_by_code(code) do
    from(c in Countries, where: c.code == ^code)
    |> Repo.all()
  end

  def get_country_by_currency(code) do
    from(c in Countries, where: c.currency_code == ^code)
    |> Repo.all()
  end

  def get_country_by_branch(branch_id) do
    from(c in Countries,
      join: b in Core.Schemas.Branch,
      on: c.id == b.country_id,
      where: b.id == ^branch_id
    )
    |> Repo.all()
  end

  def get_country_by_job(job_id) do
    from(c in Countries,
      join: b in Core.Schemas.Branch,
      on: c.id == b.country_id,
      join: bs in Core.Schemas.BranchService,
      on: b.id == bs.branch_id,
      join: j in Core.Schemas.Job,
      on: bs.id == j.branch_service_id,
      where: j.id == ^job_id,
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a countries.

  ## Examples

      iex> create_countries(%{field: value})
      {:ok, %Countries{}}

      iex> create_countries(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_countries(attrs \\ %{}) do
    %Countries{}
    |> Countries.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a countries.

  ## Examples

      iex> update_countries(countries, %{field: new_value})
      {:ok, %Countries{}}

      iex> update_countries(countries, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_countries(%Countries{} = countries, attrs) do
    countries
    |> Countries.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Countries.

  ## Examples

      iex> delete_countries(countries)
      {:ok, %Countries{}}

      iex> delete_countries(countries)
      {:error, %Ecto.Changeset{}}

  """
  def delete_countries(%Countries{} = countries) do
    Repo.delete(countries)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking countries changes.

  ## Examples

      iex> change_countries(countries)
      %Ecto.Changeset{source: %Countries{}}

  """
  def change_countries(%Countries{} = countries) do
    Countries.changeset(countries, %{})
  end

  @doc """
  Returns the list of states.

  ## Examples

      iex> list_states()
      [%States{}, ...]

  """
  def list_states do
    Repo.all(States)
  end

  @doc """
  Gets a single states.

  Raises `Ecto.NoResultsError` if the States does not exist.

  ## Examples

      iex> get_states!(123)
      %States{}

      iex> get_states!(456)
      ** (Ecto.NoResultsError)

  """
  def get_states!(id), do: Repo.get!(States, id)

  @doc """
  Creates a states.

  ## Examples

      iex> create_states(%{field: value})
      {:ok, %States{}}

      iex> create_states(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_states(attrs \\ %{}) do
    %States{}
    |> States.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a states.

  ## Examples

      iex> update_states(states, %{field: new_value})
      {:ok, %States{}}

      iex> update_states(states, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_states(%States{} = states, attrs) do
    states
    |> States.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a States.

  ## Examples

      iex> delete_states(states)
      {:ok, %States{}}

      iex> delete_states(states)
      {:error, %Ecto.Changeset{}}

  """
  def delete_states(%States{} = states) do
    Repo.delete(states)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking states changes.

  ## Examples

      iex> change_states(states)
      %Ecto.Changeset{source: %States{}}

  """
  def change_states(%States{} = states) do
    States.changeset(states, %{})
  end

  @doc """
  Returns the list of cities.

  ## Examples

      iex> list_cities()
      [%Cities{}, ...]

  """
  def list_cities do
    Repo.all(Cities)
  end

  @doc """
  Gets a single cities.

  Raises `Ecto.NoResultsError` if the Cities does not exist.

  ## Examples

      iex> get_cities!(123)
      %Cities{}

      iex> get_cities!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cities!(id), do: Repo.get!(Cities, id)
  def get_cities(id), do: Repo.get(Cities, id)

  @doc """
  Creates a cities.

  ## Examples

      iex> create_cities(%{field: value})
      {:ok, %Cities{}}

      iex> create_cities(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cities(attrs \\ %{}) do
    %Cities{}
    |> Cities.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cities.

  ## Examples

      iex> update_cities(cities, %{field: new_value})
      {:ok, %Cities{}}

      iex> update_cities(cities, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cities(%Cities{} = cities, attrs) do
    cities
    |> Cities.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Cities.

  ## Examples

      iex> delete_cities(cities)
      {:ok, %Cities{}}

      iex> delete_cities(cities)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cities(%Cities{} = cities) do
    Repo.delete(cities)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cities changes.

  ## Examples

      iex> change_cities(cities)
      %Ecto.Changeset{source: %Cities{}}

  """
  def change_cities(%Cities{} = cities) do
    Cities.changeset(cities, %{})
  end

  @doc """
  Returns the list of languages.

  ## Examples

      iex> list_languages()
      [%Languages{}, ...]

  """
  def list_languages do
    Repo.all(Languages)
  end

  @doc """
  Gets a single languages.

  Raises `Ecto.NoResultsError` if the Languages does not exist.

  ## Examples

      iex> get_languages!(123)
      %Languages{}

      iex> get_languages!(456)
      ** (Ecto.NoResultsError)

  """
  def get_languages!(id), do: Repo.get!(Languages, id)
  def get_languages(id), do: Repo.get(Languages, id)

  @doc """
  Creates a languages.

  ## Examples

      iex> create_languages(%{field: value})
      {:ok, %Languages{}}

      iex> create_languages(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_languages(attrs \\ %{}) do
    %Languages{}
    |> Languages.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a languages.

  ## Examples

      iex> update_languages(languages, %{field: new_value})
      {:ok, %Languages{}}

      iex> update_languages(languages, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_languages(%Languages{} = languages, attrs) do
    languages
    |> Languages.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Languages.

  ## Examples

      iex> delete_languages(languages)
      {:ok, %Languages{}}

      iex> delete_languages(languages)
      {:error, %Ecto.Changeset{}}

  """
  def delete_languages(%Languages{} = languages) do
    Repo.delete(languages)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking languages changes.

  ## Examples

      iex> change_languages(languages)
      %Ecto.Changeset{source: %Languages{}}

  """
  def change_languages(%Languages{} = languages) do
    Languages.changeset(languages, %{})
  end

  @doc """
  Returns the list of units.

  ## Examples

      iex> list_units()
      [%Unit{}, ...]

  """
  def list_units do
    Repo.all(Unit)
  end

  @doc """
  Gets a single unit.

  Raises `Ecto.NoResultsError` if the Unit does not exist.

  ## Examples

      iex> get_unit!(123)
      %Unit{}

      iex> get_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_unit!(id), do: Repo.get!(Unit, id)
  def get_unit(id), do: Repo.get(Unit, id)

  def get_unit_by_country(id) do
    from(u in Unit, where: u.country_id == ^id)
    |> Repo.all()
  end

  @doc """
  Creates a unit.

  ## Examples

      iex> create_unit(%{field: value})
      {:ok, %Unit{}}

      iex> create_unit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_unit(attrs \\ %{}) do
    %Unit{}
    |> Unit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a unit.

  ## Examples

      iex> update_unit(unit, %{field: new_value})
      {:ok, %Unit{}}

      iex> update_unit(unit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_unit(%Unit{} = unit, attrs) do
    unit
    |> Unit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a unit.

  ## Examples

      iex> delete_unit(unit)
      {:ok, %Unit{}}

      iex> delete_unit(unit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_unit(%Unit{} = unit) do
    Repo.delete(unit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking unit changes.

  ## Examples

      iex> change_unit(unit)
      %Ecto.Changeset{source: %Unit{}}

  """
  def change_unit(%Unit{} = unit) do
    Unit.changeset(unit, %{})
  end
end
