defmodule Core.Schemas.Warehouse do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "warehouses" do
    field :address, :string
    field :location, Geo.PostGIS.Geometry
    field :city, :string
    field :state, :string
    field :country, :string
    field :zip_code, :string
    field :phone, :string

    belongs_to :employee, Core.Schemas.Employee

    timestamps()
  end

  @doc false
  def changeset(user_address, attrs) do
    user_address
    |> cast(attrs, [:address, :location, :city, :state, :country, :zip_code, :phone, :employee_id])
    |> validate_required([:address, :phone, :location])
  end
end
