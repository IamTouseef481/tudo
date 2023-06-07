defmodule Core.Schemas.ServiceType do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "service_types" do
    field :id, :string, primary_key: true
    field :description, :string
    field :search_tsvector, Core.CustomTypes.TsVectorType
  end

  @doc false
  def changeset(service_type, attrs) do
    service_type
    |> cast(attrs, [:id, :description, :search_tsvector])
    |> validate_required([:id])
  end
end
