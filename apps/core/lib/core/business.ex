defmodule Core.Business do
  @moduledoc """
  The Business context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{BusinessType, TermsAndCondition}

  @doc """
  Returns the list of business_types.

  ## Examples

      iex> list_business_types()
      [%BusinessType{}, ...]

  """
  def list_business_types do
    Repo.all(BusinessType)
  end

  @doc """
  Gets a single business_type.

  Raises `Ecto.NoResultsError` if the Business type does not exist.

  ## Examples

      iex> get_business_type!(123)
      %BusinessType{}

      iex> get_business_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_business_type!(id), do: Repo.get!(BusinessType, id)

  @doc """
  Creates a business_type.

  ## Examples

      iex> create_business_type(%{field: value})
      {:ok, %BusinessType{}}

      iex> create_business_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_business_type(attrs \\ %{}) do
    %BusinessType{}
    |> BusinessType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a business_type.

  ## Examples

      iex> update_business_type(business_type, %{field: new_value})
      {:ok, %BusinessType{}}

      iex> update_business_type(business_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_business_type(%BusinessType{} = business_type, attrs) do
    business_type
    |> BusinessType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BusinessType.

  ## Examples

      iex> delete_business_type(business_type)
      {:ok, %BusinessType{}}

      iex> delete_business_type(business_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_business_type(%BusinessType{} = business_type) do
    Repo.delete(business_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking business_type changes.

  ## Examples

      iex> change_business_type(business_type)
      %Ecto.Changeset{source: %BusinessType{}}

  """
  def change_business_type(%BusinessType{} = business_type) do
    BusinessType.changeset(business_type, %{})
  end

  @doc """
  Returns the list of terms_and_conditions.

  ## Examples

      iex> list_terms_and_conditions()
      [%TermsAndCondition{}, ...]

  """
  def list_terms_and_conditions do
    Repo.all(TermsAndCondition)
  end

  @doc """
  Gets a single terms_and_condition.

  Raises `Ecto.NoResultsError` if the Terms and condition does not exist.

  ## Examples

      iex> get_terms_and_condition!(123)
      %TermsAndCondition{}

      iex> get_terms_and_condition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_terms_and_condition!(id), do: Repo.get!(TermsAndCondition, id)

  @doc """
  Creates a terms_and_condition.

  ## Examples

      iex> create_terms_and_condition(%{field: value})
      {:ok, %TermsAndCondition{}}

      iex> create_terms_and_condition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_terms_and_condition(attrs \\ %{}) do
    %TermsAndCondition{}
    |> TermsAndCondition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a terms_and_condition.

  ## Examples

      iex> update_terms_and_condition(terms_and_condition, %{field: new_value})
      {:ok, %TermsAndCondition{}}

      iex> update_terms_and_condition(terms_and_condition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_terms_and_condition(%TermsAndCondition{} = terms_and_condition, attrs) do
    terms_and_condition
    |> TermsAndCondition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TermsAndCondition.

  ## Examples

      iex> delete_terms_and_condition(terms_and_condition)
      {:ok, %TermsAndCondition{}}

      iex> delete_terms_and_condition(terms_and_condition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_terms_and_condition(%TermsAndCondition{} = terms_and_condition) do
    Repo.delete(terms_and_condition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking terms_and_condition changes.

  ## Examples

      iex> change_terms_and_condition(terms_and_condition)
      %Ecto.Changeset{source: %TermsAndCondition{}}

  """
  def change_terms_and_condition(%TermsAndCondition{} = terms_and_condition) do
    TermsAndCondition.changeset(terms_and_condition, %{})
  end
end
