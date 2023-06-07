defmodule Core.Schemas.DynamicGroup do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "dynamic_groups" do
    field :name, :string
    field :description, :string
    belongs_to :business, Core.Schemas.Business
    has_many :dynamic_field, Core.Schemas.DynamicField
    timestamps()
  end

  @doc false
  def changeset(dynamic_field, attrs) do
    dynamic_field
    |> cast(attrs, [:business_id, :name, :description])
    |> validate_required([:name])
  end
end
