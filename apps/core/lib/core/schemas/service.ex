defmodule Core.Schemas.Service do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{ServiceGroup, ServiceStatus, ServiceType}

  schema "services" do
    field :name, :string
    field :search_tsvector, Core.CustomTypes.TsVectorType
    belongs_to :service_status, ServiceStatus, type: :string
    belongs_to :service_group, ServiceGroup
    belongs_to :service_type, ServiceType, type: :string

    timestamps()
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [
      :name,
      :service_group_id,
      :service_type_id,
      :service_status_id,
      :search_tsvector
    ])
    |> validate_required([:name, :service_group_id, :service_type_id])
  end
end
