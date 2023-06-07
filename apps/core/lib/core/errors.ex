defmodule Core.Errors do
  @moduledoc """
  The Errors context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.DartError

  @doc """
  Returns the list of dart_errors.

  ## Examples

      iex> list_dart_errors()
      [%DartError{}, ...]

  """
  def list_dart_errors do
    Repo.all(DartError)
  end

  @doc """
  Gets a single dart_error.

  Raises `Ecto.NoResultsError` if the Dart error does not exist.

  ## Examples

      iex> get_dart_error!(123)
      %DartError{}

      iex> get_dart_error!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dart_error!(id), do: Repo.get!(DartError, id)
  def get_dart_error(id), do: Repo.get(DartError, id)

  @doc """
  Creates a dart_error.

  ## Examples

      iex> create_dart_error(%{field: value})
      {:ok, %DartError{}}

      iex> create_dart_error(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dart_error(attrs \\ %{}) do
    %DartError{}
    |> DartError.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dart_error.

  ## Examples

      iex> update_dart_error(dart_error, %{field: new_value})
      {:ok, %DartError{}}

      iex> update_dart_error(dart_error, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dart_error(%DartError{} = dart_error, attrs) do
    dart_error
    |> DartError.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dart_error.

  ## Examples

      iex> delete_dart_error(dart_error)
      {:ok, %DartError{}}

      iex> delete_dart_error(dart_error)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dart_error(%DartError{} = dart_error) do
    Repo.delete(dart_error)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dart_error changes.

  ## Examples

      iex> change_dart_error(dart_error)
      %Ecto.Changeset{source: %DartError{}}

  """
  def change_dart_error(%DartError{} = dart_error) do
    DartError.changeset(dart_error, %{})
  end
end
