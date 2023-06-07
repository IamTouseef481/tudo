defmodule Core.Schemas.Tax do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "taxes" do
    field :title, :string
    field :description, :string
    field :value, :float
    field :is_percentage, :boolean, default: true
    belongs_to :business, Core.Schemas.Business
    belongs_to :tax_type, Core.Schemas.Dropdown

    timestamps()
  end

  @doc false
  def changeset(tax, attrs) do
    tax
    |> cast(attrs, [:title, :description, :value, :is_percentage, :business_id, :tax_type_id])
    |> validate_required([:title, :value, :is_percentage])
  end
end
