defmodule Core.Schemas.DisputeCategory do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "dispute_categories" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(dispute_category, attrs) do
    dispute_category
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
