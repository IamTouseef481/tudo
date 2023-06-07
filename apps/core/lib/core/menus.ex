defmodule Core.Menus do
  @moduledoc """
  The Menus context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{Menu, MenuRole}

  @doc """
  Returns the list of menus.

  ## Examples

      iex> list_menus()
      [%Menu{}, ...]

  """
  def list_menus do
    Repo.all(Menu)
  end

  @doc """
  Gets a single menu.

  Raises `Ecto.NoResultsError` if the Menu does not exist.

  ## Examples

      iex> get_menu!(123)
      %Menu{}

      iex> get_menu!(456)
      ** (Ecto.NoResultsError)

  """
  def get_menu!(id), do: Repo.get!(Menu, id)

  @doc """
  Creates a menu.

  ## Examples

      iex> create_menu(%{field: value})
      {:ok, %Menu{}}

      iex> create_menu(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_menu(attrs \\ %{}) do
    %Menu{}
    |> Menu.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a menu.

  ## Examples

      iex> update_menu(menu, %{field: new_value})
      {:ok, %Menu{}}

      iex> update_menu(menu, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_menu(%Menu{} = menu, attrs) do
    menu
    |> Menu.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Menu.

  ## Examples

      iex> delete_menu(menu)
      {:ok, %Menu{}}

      iex> delete_menu(menu)
      {:error, %Ecto.Changeset{}}

  """
  def delete_menu(%Menu{} = menu) do
    Repo.delete(menu)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking menu changes.

  ## Examples

      iex> change_menu(menu)
      %Ecto.Changeset{source: %Menu{}}

  """
  def change_menu(%Menu{} = menu) do
    Menu.changeset(menu, %{})
  end

  @doc """
  Returns the list of menu_roles.

  ## Examples

      iex> list_menu_roles()
      [%MenuRole{}, ...]

  """
  #  def list_menu_roles do
  #    Repo.all(MenuRole)
  #  end
  def list_menu_roles(role) do
    query =
      from p in MenuRole, join: c in Menu, on: c.id == p.menu_id, where: p.acl_role_id in ^role

    from([p, c] in query)
    |> preload(:acl_role)
    |> Repo.all()
  end

  @doc """
  Gets a single menu_role.

  Raises `Ecto.NoResultsError` if the Menu role does not exist.

  ## Examples

      iex> get_menu_role!(123)
      %MenuRole{}

      iex> get_menu_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_menu_role!(id), do: Repo.get!(MenuRole, id)

  @doc """
  Creates a menu_role.

  ## Examples

      iex> create_menu_role(%{field: value})
      {:ok, %MenuRole{}}

      iex> create_menu_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_menu_role(attrs \\ %{}) do
    %MenuRole{}
    |> MenuRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a menu_role.

  ## Examples

      iex> update_menu_role(menu_role, %{field: new_value})
      {:ok, %MenuRole{}}

      iex> update_menu_role(menu_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_menu_role(%MenuRole{} = menu_role, attrs) do
    menu_role
    |> MenuRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a MenuRole.

  ## Examples

      iex> delete_menu_role(menu_role)
      {:ok, %MenuRole{}}

      iex> delete_menu_role(menu_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_menu_role(%MenuRole{} = menu_role) do
    Repo.delete(menu_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking menu_role changes.

  ## Examples

      iex> change_menu_role(menu_role)
      %Ecto.Changeset{source: %MenuRole{}}

  """
  def change_menu_role(%MenuRole{} = menu_role) do
    MenuRole.changeset(menu_role, %{})
  end
end
