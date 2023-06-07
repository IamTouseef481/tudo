defmodule Core.Schemas.DynamicFieldValue do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "dynamic_field_values" do
    field :end_point, :map
    field :fixed, :map
    field :query, :map
  end

  @doc false
  def changeset(dynamic_field_values, attrs) do
    dynamic_field_values
    |> cast(attrs, [:fixed, :end_point, :query])
    |> validate_required([:fixed, :end_point, :query])
  end
end
