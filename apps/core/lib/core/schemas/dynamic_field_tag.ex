defmodule Core.Schemas.DynamicFieldTag do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "dynamic_field_tags" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(dynamic_field_tag, attrs) do
    dynamic_field_tag
    |> cast(attrs, [:id, :description])
    |> validate_required([:id, :description])
  end
end
