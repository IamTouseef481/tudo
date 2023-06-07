defmodule Core.Schemas.ServiceSetting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.CountryService

  schema "service_settings" do
    field :fields, :map
    belongs_to :country_service, CountryService

    timestamps()
  end

  @doc false
  def changeset(service_setting, attrs) do
    service_setting
    |> cast(attrs, [:fields, :country_service_id])
    |> validate_required([:fields, :country_service_id])
  end
end
