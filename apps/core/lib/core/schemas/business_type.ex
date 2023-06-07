defmodule Core.Schemas.BusinessType do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "business_types" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(business_type, attrs) do
    business_type
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
