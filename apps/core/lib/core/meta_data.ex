defmodule Core.MetaData do
  @moduledoc """
  The MetaData context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{MetaBSP, MetaCMR}

  @doc """
  Returns the list of meta.

  ## Examples

      iex> list_meta_bsp()
      [%Meta{}, ...]

  """
  def list_meta_bsp do
    Repo.all(MetaBSP)
  end

  def list_meta_bsp_preloaded_user_and_installs do
    Repo.all(from m in MetaBSP, preload: [user: :user_installs])
  end

  @doc """
  Gets a single meta.

  Raises `Ecto.NoResultsError` if the Meta does not exist.

  ## Examples

      iex> get_meta_bsp!(123)
      %Meta{}

      iex> get_meta_bsp!(456)
      ** (Ecto.NoResultsError)

  """
  def get_meta_bsp!(id), do: Repo.get!(MetaBSP, id)
  def get_meta_bsp(id), do: Repo.get(MetaBSP, id)

  def get_meta_bsp_by(%{employee_id: employee_id, type: type, user_id: user_id}) do
    from(m in MetaBSP,
      where: m.employee_id == ^employee_id and m.type == ^type and m.user_id == ^user_id
    )
    |> Repo.all()
  end

  def get_dashboard_meta_by_employee_id(employee_id, branch_id, type) do
    from(m in MetaBSP,
      where: m.employee_id == ^employee_id and m.branch_id == ^branch_id and m.type == ^type
    )
    |> Repo.all()
  end

  @doc """
  Creates a meta.

  ## Examples

      iex> create_meta_bsp(%{field: value})
      {:ok, %Meta{}}

      iex> create_meta_bsp(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_meta_bsp(attrs \\ %{}) do
    %MetaBSP{}
    |> MetaBSP.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a meta.

  ## Examples

      iex> update_meta_bsp(meta, %{field: new_value})
      {:ok, %Meta{}}

      iex> update_meta_bsp(meta, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_meta_bsp(%MetaBSP{} = meta, attrs) do
    meta
    |> MetaBSP.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Meta.

  ## Examples

      iex> delete_meta_bsp(meta)
      {:ok, %Meta{}}

      iex> delete_meta_bsp(meta)
      {:error, %Ecto.Changeset{}}

  """
  def delete_meta_bsp(%MetaBSP{} = meta) do
    Repo.delete(meta)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meta changes.

  ## Examples

      iex> change_meta_bsp(meta)
      %Ecto.Changeset{source: %Meta{}}

  """
  def change_meta_bsp(%MetaBSP{} = meta) do
    MetaBSP.changeset(meta, %{})
  end

  @doc """
  Returns the list of meta_cmr.

  ## Examples

      iex> list_meta_cmr()
      [%MetaCMR{}, ...]

  """
  def list_meta_cmr do
    Repo.all(MetaCMR)
  end

  def list_meta_cmr_preloaded_user_and_installs do
    Repo.all(from m in MetaCMR, preload: [user: :user_installs])
  end

  @doc """
  Gets a single meta_cmr.

  Raises `Ecto.NoResultsError` if the Meta cmr does not exist.

  ## Examples

      iex> get_meta_cmr!(123)
      %MetaCMR{}

      iex> get_meta_cmr!(456)
      ** (Ecto.NoResultsError)

  """
  def get_meta_cmr!(id), do: Repo.get!(MetaCMR, id)
  def get_meta_cmr(id), do: Repo.get(MetaCMR, id)

  def get_meta_cmr_by(%{type: type, user_id: user_id}) do
    from(m in MetaCMR, where: m.type == ^type and m.user_id == ^user_id)
    |> Repo.all()
  end

  def get_dashboard_meta_by_user_id(user_id, type) do
    from(m in MetaCMR, where: m.user_id == ^user_id and m.type == ^type)
    |> Repo.all()
  end

  @doc """
  Creates a meta_cmr.

  ## Examples

      iex> create_meta_cmr(%{field: value})
      {:ok, %MetaCMR{}}

      iex> create_meta_cmr(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_meta_cmr(attrs \\ %{}) do
    %MetaCMR{}
    |> MetaCMR.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a meta_cmr.

  ## Examples

      iex> update_meta_cmr(meta_cmr, %{field: new_value})
      {:ok, %MetaCMR{}}

      iex> update_meta_cmr(meta_cmr, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_meta_cmr(%MetaCMR{} = meta_cmr, attrs) do
    meta_cmr
    |> MetaCMR.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a meta_cmr.

  ## Examples

      iex> delete_meta_cmr(meta_cmr)
      {:ok, %MetaCMR{}}

      iex> delete_meta_cmr(meta_cmr)
      {:error, %Ecto.Changeset{}}

  """
  def delete_meta_cmr(%MetaCMR{} = meta_cmr) do
    Repo.delete(meta_cmr)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meta_cmr changes.

  ## Examples

      iex> change_meta_cmr(meta_cmr)
      %Ecto.Changeset{source: %MetaCMR{}}

  """
  def change_meta_cmr(%MetaCMR{} = meta_cmr) do
    MetaCMR.changeset(meta_cmr, %{})
  end
end
