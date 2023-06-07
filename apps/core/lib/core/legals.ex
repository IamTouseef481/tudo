defmodule Core.Legals do
  @moduledoc """
  The Legals context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{LicenceIssuingAuthorities, PlatformTermAndCondition}

  @doc """
  Returns the list of licence_issuing_authorities.

  ## Examples

      iex> list_licence_issuing_authorities()
      [%LicenceIssuingAuthorities{}, ...]

  """
  def list_licence_issuing_authorities do
    Repo.all(LicenceIssuingAuthorities)
  end

  @doc """
  Gets a single licence_issuing_authorities.

  Raises `Ecto.NoResultsError` if the Licence issuing authorities does not exist.

  ## Examples

      iex> get_licence_issuing_authorities!(123)
      %LicenceIssuingAuthorities{}

      iex> get_licence_issuing_authorities!(456)
      ** (Ecto.NoResultsError)

  """
  def get_licence_issuing_authorities!(id), do: Repo.get!(LicenceIssuingAuthorities, id)
  def get_licence_issuing_authorities(id), do: Repo.get(LicenceIssuingAuthorities, id)

  def get_licence_issuing_authorities_by_country(country_id) do
    from(p in LicenceIssuingAuthorities,
      where: (p.country_id == ^country_id or p.country_id == 1) and p.is_active == true
    )
    |> Repo.all()
  end

  @doc """
  Creates a licence_issuing_authorities.

  ## Examples

      iex> create_licence_issuing_authorities(%{field: value})
      {:ok, %LicenceIssuingAuthorities{}}

      iex> create_licence_issuing_authorities(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_licence_issuing_authorities(attrs \\ %{}) do
    %LicenceIssuingAuthorities{}
    |> LicenceIssuingAuthorities.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a licence_issuing_authorities.

  ## Examples

      iex> update_licence_issuing_authorities(licence_issuing_authorities, %{field: new_value})
      {:ok, %LicenceIssuingAuthorities{}}

      iex> update_licence_issuing_authorities(licence_issuing_authorities, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_licence_issuing_authorities(
        %LicenceIssuingAuthorities{} = licence_issuing_authorities,
        attrs
      ) do
    licence_issuing_authorities
    |> LicenceIssuingAuthorities.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a LicenceIssuingAuthorities.

  ## Examples

      iex> delete_licence_issuing_authorities(licence_issuing_authorities)
      {:ok, %LicenceIssuingAuthorities{}}

      iex> delete_licence_issuing_authorities(licence_issuing_authorities)
      {:error, %Ecto.Changeset{}}

  """
  def delete_licence_issuing_authorities(
        %LicenceIssuingAuthorities{} = licence_issuing_authorities
      ) do
    Repo.delete(licence_issuing_authorities)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking licence_issuing_authorities changes.

  ## Examples

      iex> change_licence_issuing_authorities(licence_issuing_authorities)
      %Ecto.Changeset{source: %LicenceIssuingAuthorities{}}

  """
  def change_licence_issuing_authorities(
        %LicenceIssuingAuthorities{} = licence_issuing_authorities
      ) do
    LicenceIssuingAuthorities.changeset(licence_issuing_authorities, %{})
  end

  @doc """
  Returns the list of platform_terms_and_conditions.

  ## Examples

      iex> list_platform_terms_and_conditions()
      [%PlatformTermAndCondition{}, ...]

  """
  def list_platform_terms_and_conditions do
    Repo.all(PlatformTermAndCondition)
  end

  @doc """
  Gets a single platform_term_and_condition.

  Raises `Ecto.NoResultsError` if the Platform term and condition does not exist.

  ## Examples

      iex> get_platform_term_and_condition!(123)
      %PlatformTermAndCondition{}

      iex> get_platform_term_and_condition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_platform_term_and_condition!(id), do: Repo.get!(PlatformTermAndCondition, id)
  def get_platform_term_and_condition(id), do: Repo.get(PlatformTermAndCondition, id)

  def get_platform_terms_and_conditions_by_country(country_id) do
    from(p in PlatformTermAndCondition, where: p.country_id == ^country_id)
    |> Repo.all()
  end

  @doc """
  Creates a platform_term_and_condition.

  ## Examples

      iex> create_platform_term_and_condition(%{field: value})
      {:ok, %PlatformTermAndCondition{}}

      iex> create_platform_term_and_condition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_platform_term_and_condition(attrs \\ %{}) do
    %PlatformTermAndCondition{}
    |> PlatformTermAndCondition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a platform_term_and_condition.

  ## Examples

      iex> update_platform_term_and_condition(platform_term_and_condition, %{field: new_value})
      {:ok, %PlatformTermAndCondition{}}

      iex> update_platform_term_and_condition(platform_term_and_condition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_platform_term_and_condition(
        %PlatformTermAndCondition{} = platform_term_and_condition,
        attrs
      ) do
    platform_term_and_condition
    |> PlatformTermAndCondition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PlatformTermAndCondition.

  ## Examples

      iex> delete_platform_term_and_condition(platform_term_and_condition)
      {:ok, %PlatformTermAndCondition{}}

      iex> delete_platform_term_and_condition(platform_term_and_condition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_platform_term_and_condition(
        %PlatformTermAndCondition{} = platform_term_and_condition
      ) do
    Repo.delete(platform_term_and_condition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking platform_term_and_condition changes.

  ## Examples

      iex> change_platform_term_and_condition(platform_term_and_condition)
      %Ecto.Changeset{source: %PlatformTermAndCondition{}}

  """
  def change_platform_term_and_condition(
        %PlatformTermAndCondition{} = platform_term_and_condition
      ) do
    PlatformTermAndCondition.changeset(platform_term_and_condition, %{})
  end
end
