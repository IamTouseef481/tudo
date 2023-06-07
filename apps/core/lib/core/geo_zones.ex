defmodule Core.GeoZones do
  @moduledoc """
  The GeoZones context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.GeoZone

  @doc """
  Returns the list of geo_zones.

  ## Examples

      iex> list_geo_zones()
      [%GeoZone{}, ...]

  """
  def list_geo_zones do
    Repo.all(GeoZone)
  end

  @doc """
  Gets a single geo_zone.

  Raises `Ecto.NoResultsError` if the Geo zone does not exist.

  ## Examples

      iex> get_geo_zone!(123)
      %GeoZone{}

      iex> get_geo_zone!(456)
      ** (Ecto.NoResultsError)

  """
  def get_geo_zone!(id), do: Repo.get!(GeoZone, id)
  #  for get zones endpoint
  def get_geo_zone_by_country_id(%{country_id: country_id}) do
    from(gz in GeoZone, where: gz.country_id == ^country_id)
    |> Repo.all()
  end

  #  for branch use
  def get_geo_zone_by_country_id(country_id) do
    from(gz in GeoZone, where: gz.country_id == ^country_id, select: gz.id)
    |> Repo.all()
  end

  @doc """
  Creates a geo_zone.

  ## Examples

      iex> create_geo_zone(%{field: value})
      {:ok, %GeoZone{}}

      iex> create_geo_zone(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_geo_zone(attrs \\ %{}) do
    %GeoZone{}
    |> GeoZone.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a geo_zone.

  ## Examples

      iex> update_geo_zone(geo_zone, %{field: new_value})
      {:ok, %GeoZone{}}

      iex> update_geo_zone(geo_zone, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_geo_zone(%GeoZone{} = geo_zone, attrs) do
    geo_zone
    |> GeoZone.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a GeoZone.

  ## Examples

      iex> delete_geo_zone(geo_zone)
      {:ok, %GeoZone{}}

      iex> delete_geo_zone(geo_zone)
      {:error, %Ecto.Changeset{}}

  """
  def delete_geo_zone(%GeoZone{} = geo_zone) do
    Repo.delete(geo_zone)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking geo_zone changes.

  ## Examples

      iex> change_geo_zone(geo_zone)
      %Ecto.Changeset{source: %GeoZone{}}

  """
  def change_geo_zone(%GeoZone{} = geo_zone) do
    GeoZone.changeset(geo_zone, %{})
  end
end
