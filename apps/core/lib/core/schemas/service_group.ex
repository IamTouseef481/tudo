defmodule Core.Schemas.ServiceGroup do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "service_groups" do
    field :is_active, :boolean, default: true
    field :name, :string
    field :search_tsvector, Core.CustomTypes.TsVectorType

    timestamps()
  end

  @doc false
  def changeset(service_group, attrs) do
    service_group
    |> cast(attrs, [:name, :is_active, :search_tsvector])
    |> validate_required([:name, :is_active])
  end
end
