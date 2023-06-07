defmodule Core.Referrals do
  @moduledoc """
  The Referrals context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.UserReferral

  @doc """
  Returns the list of user_referrals.

  ## Examples

      iex> list_user_referrals()
      [%UserReferral{}, ...]

  """
  def list_user_referrals do
    Repo.all(UserReferral)
  end

  @doc """
  Gets a single user_referral.

  Raises `Ecto.NoResultsError` if the User referral does not exist.

  ## Examples

      iex> get_user_referral!(123)
      %UserReferral{}

      iex> get_user_referral!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_referral!(id), do: Repo.get!(UserReferral, id)

  def get_user_referral_by(from_id, email),
    do: UserReferral |> Repo.get_by(%{email: email, user_from_id: from_id})

  @doc """
  Creates a user_referral.

  ## Examples

      iex> create_user_referral(%{field: value})
      {:ok, %UserReferral{}}

      iex> create_user_referral(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_referral(attrs \\ %{}) do
    %UserReferral{}
    |> UserReferral.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_referral.

  ## Examples

      iex> update_user_referral(user_referral, %{field: new_value})
      {:ok, %UserReferral{}}

      iex> update_user_referral(user_referral, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_referral(%UserReferral{} = user_referral, attrs) do
    user_referral
    |> UserReferral.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_referral.

  ## Examples

      iex> delete_user_referral(user_referral)
      {:ok, %UserReferral{}}

      iex> delete_user_referral(user_referral)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_referral(%UserReferral{} = user_referral) do
    Repo.delete(user_referral)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_referral changes.

  ## Examples

      iex> change_user_referral(user_referral)
      %Ecto.Changeset{source: %UserReferral{}}

  """
  def change_user_referral(%UserReferral{} = user_referral) do
    UserReferral.changeset(user_referral, %{})
  end
end
