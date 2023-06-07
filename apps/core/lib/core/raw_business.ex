defmodule Core.RawBusiness do
  @moduledoc """
  The Raw Business context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.RawBusiness

  @spec get(integer()) :: struct()
  def get(id), do: RawBusiness |> where([rb], rb.id == ^id) |> Repo.one()

  @spec get_by(any(), any(), any()) :: struct()
  def get_by(phone, name, address) do
    RawBusiness
    |> where([r_b], r_b.phone == ^phone and r_b.name == ^name and r_b.address == ^address)
    |> Repo.one()
  end

  @spec create(map()) :: struct()
  def create(attrs \\ %{}) do
    %RawBusiness{}
    |> RawBusiness.changeset(attrs)
    |> Repo.insert()
  end

  @spec update(struct(), map()) :: struct()
  def update(%RawBusiness{} = raw_business, attrs) do
    raw_business
    |> RawBusiness.changeset(attrs)
    |> Repo.update()
  end
end
