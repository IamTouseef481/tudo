defmodule Core.Schemas.Dropdown do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "dropdowns" do
    field :name, :string
    field :slug, :string
    field :type, :string
    belongs_to :country, Core.Schemas.Countries

    timestamps()
  end

  @doc false
  def changeset(dropdown, attrs) do
    dropdown
    |> cast(attrs, [:name, :slug, :type, :country_id])
    |> validate_required([:name, :slug, :type])
  end
end
