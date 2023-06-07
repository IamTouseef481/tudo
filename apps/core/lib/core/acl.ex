defmodule Core.Acl do
  @moduledoc """
  The Acl context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Acl.AclRole

  @doc """
  Returns the list of acl_roles.

  ## Examples

      iex> list_acl_roles()
      [%AclRole{}, ...]

  """
  def list_acl_roles do
    Repo.all(AclRole)
  end

  @doc """
  Gets a single acl_role.

  Raises `Ecto.NoResultsError` if the Acl role does not exist.

  ## Examples

      iex> get_acl_role!(123)
      %AclRole{}

      iex> get_acl_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_acl_role!(id), do: Repo.get!(AclRole, id)
  def get_acl_role(id), do: Repo.get(AclRole, id)

  @doc """
  Creates a acl_role.

  ## Examples

      iex> create_acl_role(%{field: value})
      {:ok, %AclRole{}}

      iex> create_acl_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_acl_role(attrs \\ %{}) do
    %AclRole{}
    |> AclRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a acl_role.

  ## Examples

      iex> update_acl_role(acl_role, %{field: new_value})
      {:ok, %AclRole{}}

      iex> update_acl_role(acl_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_acl_role(%AclRole{} = acl_role, attrs) do
    acl_role
    |> AclRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a AclRole.

  ## Examples

      iex> delete_acl_role(acl_role)
      {:ok, %AclRole{}}

      iex> delete_acl_role(acl_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_acl_role(%AclRole{} = acl_role) do
    Repo.delete(acl_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking acl_role changes.

  ## Examples

      iex> change_acl_role(acl_role)
      %Ecto.Changeset{source: %AclRole{}}

  """
  def change_acl_role(%AclRole{} = acl_role) do
    AclRole.changeset(acl_role, %{})
  end
end
