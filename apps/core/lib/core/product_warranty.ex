defmodule Core.Productwarranty do
  @moduledoc """
  The Raw Business context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{ProductWarranty, ProductType, ProductManufacturer}

  @spec get(integer()) :: struct()
  def get(id), do: ProductWarranty |> where([pw], pw.id == ^id) |> Repo.one()

  @spec create(map()) :: struct()
  def create(attrs \\ %{}) do
    %ProductWarranty{}
    |> ProductWarranty.changeset(attrs)
    |> Repo.insert()
  end

  @spec update(struct(), map()) :: struct()
  def update(%ProductWarranty{} = product_warranties, attrs) do
    product_warranties
    |> ProductWarranty.changeset(attrs)
    |> Repo.update()
  end

  def delete(%ProductWarranty{} = product_warranties) do
    product_warranties
    |> Repo.delete()
  end

  def list(id) do
    ProductWarranty
    |> where([pw], pw.user_id == ^id)
    |> Repo.all()
  end

  def list_product_type() do
    ProductType
    |> Repo.all()
  end

  def list_manufacturer_name(%{page_number: page_number, page_size: page_size, search: search}) do
    ProductManufacturer
    |> where([pm], fragment("? ilike ?", pm.id, ^"%#{search}%"))
    |> where([pm], fragment("? ilike ?", pm.description, ^"%#{search}%"))
    |> Repo.paginate(page_number: page_number, page_size: page_size)
  end

  def list_manufacturer_name(%{page_number: page_number, page_size: page_size}) do
    Repo.paginate(ProductManufacturer, page_number: page_number, page_size: page_size)
  end

  def get_manufacturer_by(id) do
    ProductManufacturer
    |> Repo.get_by(id: id)
  end

  def create_manufacturer(attrs \\ %{}) do
    %ProductManufacturer{}
    |> ProductManufacturer.changeset(attrs)
    |> Repo.insert()
  end
end
