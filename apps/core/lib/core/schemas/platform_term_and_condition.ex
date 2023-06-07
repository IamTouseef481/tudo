defmodule Core.Schemas.PlatformTermAndCondition do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.Countries

  schema "platform_terms_and_conditions" do
    field :slug, :string
    field :type, :string
    field :text, :string
    field :url, :string
    field :end_date, :utc_datetime
    field :start_date, :utc_datetime
    belongs_to :country, Countries

    timestamps()
  end

  @doc false
  def changeset(platform_term_and_condition, attrs) do
    platform_term_and_condition
    |> cast(attrs, [:slug, :text, :type, :url, :start_date, :end_date, :country_id])
    |> validate_required([:slug, :type, :start_date, :end_date, :country_id])
  end
end
