defmodule Core.OffDays do
  @moduledoc """
  The OffDays context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.Holiday

  @doc """
  Returns the list of holidays.

  ## Examples

      iex> list_holidays()
      [%Holiday{}, ...]

  """
  def list_holidays do
    Repo.all(Holiday)
  end

  @doc """
  Gets a single holiday.

  Raises `Ecto.NoResultsError` if the Holiday does not exist.

  ## Examples

      iex> get_holiday!(123)
      %Holiday{}

      iex> get_holiday!(456)
      ** (Ecto.NoResultsError)

  """
  def get_holiday!(id), do: Repo.get!(Holiday, id)
  def get_holiday(params), do: Repo.get_by(Holiday, params)

  def get_holiday_by(%{branch_id: branch_id, to: to, from: from}) do
    from(h in Holiday,
      where: h.branch_id == ^branch_id,
      where: h.from >= ^from,
      where: h.to <= ^to
    )
    |> Repo.all()
  end

  def get_holiday_by_branch(%{branch_id: branch_id}) do
    from(h in Holiday, where: h.branch_id == ^branch_id)
    |> Repo.all()
  end

  @doc """
  Creates a holiday.

  ## Examples

      iex> create_holiday(%{field: value})
      {:ok, %Holiday{}}

      iex> create_holiday(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_holiday(attrs \\ %{}) do
    %Holiday{}
    |> Holiday.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a holiday.

  ## Examples

      iex> update_holiday(holiday, %{field: new_value})
      {:ok, %Holiday{}}

      iex> update_holiday(holiday, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_holiday(%Holiday{} = holiday, attrs) do
    holiday
    |> Holiday.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Holiday.

  ## Examples

      iex> delete_holiday(holiday)
      {:ok, %Holiday{}}

      iex> delete_holiday(holiday)
      {:error, %Ecto.Changeset{}}

  """
  def delete_holiday(%Holiday{} = holiday) do
    Repo.delete(holiday)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking holiday changes.

  ## Examples

      iex> change_holiday(holiday)
      %Ecto.Changeset{source: %Holiday{}}

  """
  def change_holiday(%Holiday{} = holiday) do
    Holiday.changeset(holiday, %{})
  end
end
