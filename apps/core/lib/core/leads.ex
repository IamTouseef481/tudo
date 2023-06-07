defmodule Core.Leads do
  @moduledoc """
  The Leads context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Schemas.Lead

  @doc """
  Returns the list of leads.

  ## Examples

      iex> list_leads()
      [%Lead{}, ...]

  """
  def list_leads do
    Repo.all(Lead)
  end

  @doc """
  Gets a single lead.

  Raises `Ecto.NoResultsError` if the Lead does not exist.

  ## Examples

      iex> get_lead!(123)
      %Lead{}

      iex> get_lead!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lead!(id), do: Repo.get!(Lead, id)
  def get_lead(id), do: Repo.get(Lead, id)

  def get_leads_by(%{
        user_id: user_id,
        country_service_id: cs_id,
        location: location,
        arrive_at: arrive_at
      }) do
    from(l in Lead,
      where:
        l.country_service_id == ^cs_id and l.user_id == ^user_id and l.arrive_at == ^arrive_at and
          l.location == ^location
    )
    |> Repo.all()
  end

  def get_leads_by_location(branch_location, radius_limit) do
    from(l in Lead,
      where: fragment("calculate_distance(?,?,?)", ^branch_location, l.location, ^radius_limit)
    )
    |> Repo.all()
  end

  def get_leads_by_location_for_marketing_group(branch_location) do
    from(l in Lead,
      where:
        fragment(
          "calculate_distance_for_marketing_group(?,?,?)",
          l.location,
          ^branch_location,
          150
        ),
      distinct: l.user_id,
      select: l.user_id
    )
    |> Repo.all()
  end

  # This function is not properly working. We are getting too much big list by using this technique.
  #    def get_leads_by_location_for_marketing_group(branch_location) do
  ##    branch_location = CoreWeb.Utils.CommonFunctions.encode_location(branch_location)
  ##    branch_location = Geo.WKB.encode!(branch_location)
  #    query = from(l in Lead,
  #      full_join: add in UserAddress,
  #      where: fragment("calculate_distance_for_marketing_group(?,?,?)", l.location, ^branch_location, 150)
  #      or fragment("calculate_distance_for_marketing_group(?,?,?)", add.geo_location, ^branch_location, 150),
  #      distinct: [l.user_id, add.user_id],
  #      select: [l.user_id, add.user_id])
  #      Repo.all(query)
  #  end

  def get_leads_by_country_services(cs_ids) do
    from(l in Lead,
      where: l.country_service_id in ^cs_ids
    )
    |> Repo.all()
  end

  @doc """
  Creates a lead.

  ## Examples

      iex> create_lead(%{field: value})
      {:ok, %Lead{}}

      iex> create_lead(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lead(attrs \\ %{}) do
    %Lead{}
    |> Lead.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lead.

  ## Examples

      iex> update_lead(lead, %{field: new_value})
      {:ok, %Lead{}}

      iex> update_lead(lead, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lead(%Lead{} = lead, attrs) do
    lead
    |> Lead.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lead.

  ## Examples

      iex> delete_lead(lead)
      {:ok, %Lead{}}

      iex> delete_lead(lead)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lead(%Lead{} = lead) do
    Repo.delete(lead)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lead changes.

  ## Examples

      iex> change_lead(lead)
      %Ecto.Changeset{source: %Lead{}}

  """
  def change_lead(%Lead{} = lead) do
    Lead.changeset(lead, %{})
  end
end
