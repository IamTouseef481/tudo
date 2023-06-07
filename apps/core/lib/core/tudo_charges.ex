defmodule Core.TudoCharges do
  @moduledoc """
  The TudoCharges context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.TudoCharge

  @doc """
  Returns the list of tudo_charges.

  ## Examples

      iex> list_tudo_charges()
      [%TudoCharge{}, ...]

  """
  def list_tudo_charges do
    Repo.all(TudoCharge)
  end

  @doc """
  Gets a single tudo_charge.

  Raises `Ecto.NoResultsError` if the Tudo charge does not exist.

  ## Examples

      iex> get_tudo_charge!(123)
      %TudoCharge{}

      iex> get_tudo_charge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tudo_charge!(id), do: Repo.get!(TudoCharge, id)
  def get_tudo_charge(id), do: Repo.get(TudoCharge, id)

  def get_tudo_charges_by_slug(slug, country_id) do
    from(c in TudoCharge,
      where: c.slug == ^slug and (c.country_id == ^country_id or c.country_id == 1),
      where: is_nil(c.application_id) and is_nil(c.branch_id)
    )
    |> Repo.one()
  end

  def get_tudo_charges_by_slug(slug, country_id, nil),
    do: get_tudo_charges_by_slug(slug, country_id)

  def get_tudo_charges_by_slug(slug, country_id, branch_id) do
    application_id = Application.get_env(:core, :application_name) || "tudo"

    from(c in TudoCharge,
      where: c.slug == ^slug,
      where: c.country_id == ^country_id or c.country_id == 1,
      where: c.branch_id == ^branch_id,
      where: c.application_id == ^application_id
    )
    |> Repo.one() || get_tudo_charges_by_slug(slug, country_id)
  end

  @doc """
  Creates a tudo_charge.

  ## Examples

      iex> create_tudo_charge(%{field: value})
      {:ok, %TudoCharge{}}

      iex> create_tudo_charge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tudo_charge(attrs \\ %{}) do
    %TudoCharge{}
    |> TudoCharge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tudo_charge.

  ## Examples

      iex> update_tudo_charge(tudo_charge, %{field: new_value})
      {:ok, %TudoCharge{}}

      iex> update_tudo_charge(tudo_charge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tudo_charge(%TudoCharge{} = tudo_charge, attrs) do
    tudo_charge
    |> TudoCharge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tudo_charge.

  ## Examples

      iex> delete_tudo_charge(tudo_charge)
      {:ok, %TudoCharge{}}

      iex> delete_tudo_charge(tudo_charge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tudo_charge(%TudoCharge{} = tudo_charge) do
    Repo.delete(tudo_charge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tudo_charge changes.

  ## Examples

      iex> change_tudo_charge(tudo_charge)
      %Ecto.Changeset{source: %TudoCharge{}}

  """
  def change_tudo_charge(%TudoCharge{} = tudo_charge) do
    TudoCharge.changeset(tudo_charge, %{})
  end
end
