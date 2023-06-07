defmodule Core.Schemas.Lead do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.CountryService
  alias Core.Schemas.User

  schema "leads" do
    field :arrive_at, :utc_datetime
    field :is_flexible, :boolean, default: false
    field :location, Geo.PostGIS.Geometry
    field :rating, :float
    belongs_to :country_service, CountryService
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(lead, attrs) do
    lead
    |> cast(attrs, [:arrive_at, :location, :rating, :is_flexible, :country_service_id, :user_id])
    |> validate_required([:location, :user_id])
  end
end
