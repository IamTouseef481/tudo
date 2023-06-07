defmodule Core.Schemas.CountryService do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{Countries, DynamicField, Service}

  schema "country_services" do
    field :is_active, :boolean, default: true
    belongs_to :country, Countries
    belongs_to :service, Service
    belongs_to :dynamic_field, DynamicField

    timestamps()
  end

  @doc false
  def changeset(country_service, attrs) do
    country_service
    |> cast(attrs, [:country_id, :service_id, :dynamic_field_id, :is_active])
    |> validate_required([:country_id, :service_id, :is_active])
  end
end
