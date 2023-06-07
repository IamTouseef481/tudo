defmodule TudoChat.FriendCircles do
  @moduledoc """
  The FriendCircles context.
  """

  import Ecto.Query, warn: false
  alias TudoChat.Repo

  alias TudoChat.FriendCircles.{FriendCircle, FriendCircleStatus}

  @doc """
  Returns the list of friend_circle_status.

  ## Examples

      iex> list_friend_circle_status()
      [%FriendCircleStatus{}, ...]

  """
  def list_friend_circle_statuses do
    Repo.all(FriendCircleStatus)
  end

  @doc """
  Gets a single friend_circle_status.

  Raises `Ecto.NoResultsError` if the Friend circle does not exist.

  ## Examples

      iex> get_friend_circle_status!(123)
      %FriendCircleStatus{}

      iex> get_friend_circle_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_friend_circle_status!(id), do: Repo.get!(FriendCircleStatus, id)
  def get_friend_circle_status(id), do: Repo.get(FriendCircleStatus, id)

  @doc """
  Creates a friend_circle_status.

  ## Examples

      iex> create_friend_circle_status(%{field: value})
      {:ok, %FriendCircleStatus{}}

      iex> create_friend_circle_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_friend_circle_status(attrs \\ %{}) do
    %FriendCircleStatus{}
    |> FriendCircleStatus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a friend_circle_status.

  ## Examples

      iex> update_friend_circle_status(friend_circle_status, %{field: new_value})
      {:ok, %FriendCircleStatus{}}

      iex> update_friend_circle_status(friend_circle_status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_friend_circle_status(%FriendCircleStatus{} = friend_circle_status, attrs) do
    friend_circle_status
    |> FriendCircleStatus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a friend_circle_status.

  ## Examples

      iex> delete_friend_circle_status(friend_circle_status)
      {:ok, %FriendCircleStatus{}}

      iex> delete_friend_circle_status(friend_circle_status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_friend_circle_status(%FriendCircleStatus{} = friend_circle_status) do
    Repo.delete(friend_circle_status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking friend_circle_status changes.

  ## Examples

      iex> change_friend_circle_status(friend_circle_status)
      %Ecto.Changeset{source: %FriendCircleStatus{}}

  """
  def change_friend_circle_status(%FriendCircleStatus{} = friend_circle_status) do
    FriendCircleStatus.changeset(friend_circle_status, %{})
  end

  @doc """
  Returns the list of friend_circles.

  ## Examples

      iex> list_friend_circles()
      [%FriendCircle{}, ...]

  """
  def list_friend_circles do
    Repo.all(FriendCircle)
  end

  @doc """
  Gets a single friend_circle.

  Raises `Ecto.NoResultsError` if the Friend circle does not exist.

  ## Examples

      iex> get_friend_circle!(123)
      %FriendCircle{}

      iex> get_friend_circle!(456)
      ** (Ecto.NoResultsError)

  """
  def get_friend_circle!(id), do: Repo.get!(FriendCircle, id)
  def get_friend_circle(id), do: Repo.get(FriendCircle, id)

  def get_friend_circles_by(%{user_from_id: user_from}) do
    from(fc in FriendCircle, where: fc.user_from_id == ^user_from and fc.status_id == "accept")
    |> Repo.all()
  end

  def get_friend_circle_by(%{group_id: group_id, user_to_id: user_to}) do
    from(fc in FriendCircle, where: fc.group_id == ^group_id and fc.user_to_id == ^user_to)
    |> Repo.all()
  end

  def get_friend_circle_by(%{user_from_id: user_from, status_ids: statuses}) do
    from(fc in FriendCircle, where: fc.user_from_id == ^user_from and fc.status_id in ^statuses)
    |> Repo.all()
  end

  def get_friend_circle_by(%{user_from_id: user_from}) do
    from(fc in FriendCircle, where: fc.user_from_id == ^user_from)
    |> Repo.all()
  end

  def get_friend_circle_by(%{user_to_id: user_to}) do
    from(fc in FriendCircle, where: fc.user_to_id == ^user_to and fc.status_id == "pending")
    |> Repo.all()
  end

  @doc """
  Creates a friend_circle.

  ## Examples

      iex> create_friend_circle(%{field: value})
      {:ok, %FriendCircle{}}

      iex> create_friend_circle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_friend_circle(attrs \\ %{}) do
    %FriendCircle{}
    |> FriendCircle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a friend_circle.

  ## Examples

      iex> update_friend_circle(friend_circle, %{field: new_value})
      {:ok, %FriendCircle{}}

      iex> update_friend_circle(friend_circle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_friend_circle(%FriendCircle{} = friend_circle, attrs) do
    friend_circle
    |> FriendCircle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a friend_circle.

  ## Examples

      iex> delete_friend_circle(friend_circle)
      {:ok, %FriendCircle{}}

      iex> delete_friend_circle(friend_circle)
      {:error, %Ecto.Changeset{}}

  """
  def delete_friend_circle(%FriendCircle{} = friend_circle) do
    Repo.delete(friend_circle)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking friend_circle changes.

  ## Examples

      iex> change_friend_circle(friend_circle)
      %Ecto.Changeset{source: %FriendCircle{}}

  """
  def change_friend_circle(%FriendCircle{} = friend_circle) do
    FriendCircle.changeset(friend_circle, %{})
  end
end
