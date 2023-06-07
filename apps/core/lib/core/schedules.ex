defmodule Core.Schedules do
  @moduledoc """
  The Schedules context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.UserSchedule

  @doc """
  Returns the list of user_schedules.

  ## Examples

      iex> list_user_schedules()
      [%UserSchedule{}, ...]

  """
  def list_user_schedules do
    Repo.all(UserSchedule)
  end

  @doc """
  Gets a single user_schedule.

  Raises `Ecto.NoResultsError` if the User schedule does not exist.

  ## Examples

      iex> get_user_schedule!(123)
      %UserSchedule{}

      iex> get_user_schedule!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_schedule!(id), do: Repo.get!(UserSchedule, id)
  def get_user_schedule(id), do: Repo.get(UserSchedule, id)

  @doc """
  Creates a user_schedule.

  ## Examples

      iex> create_user_schedule(%{field: value})
      {:ok, %UserSchedule{}}

      iex> create_user_schedule(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_schedule(attrs \\ %{}) do
    %UserSchedule{}
    |> UserSchedule.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_schedule.

  ## Examples

      iex> update_user_schedule(user_schedule, %{field: new_value})
      {:ok, %UserSchedule{}}

      iex> update_user_schedule(user_schedule, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_schedule(%UserSchedule{} = user_schedule, attrs) do
    user_schedule
    |> UserSchedule.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserSchedule.

  ## Examples

      iex> delete_user_schedule(user_schedule)
      {:ok, %UserSchedule{}}

      iex> delete_user_schedule(user_schedule)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_schedule(%UserSchedule{} = user_schedule) do
    Repo.delete(user_schedule)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_schedule changes.

  ## Examples

      iex> change_user_schedule(user_schedule)
      %Ecto.Changeset{source: %UserSchedule{}}

  """
  def change_user_schedule(%UserSchedule{} = user_schedule) do
    UserSchedule.changeset(user_schedule, %{})
  end
end
