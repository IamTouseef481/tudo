defmodule Core.Schemas.Donation do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "donations" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :amount, :float
    field :status, :string
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime
    belongs_to :country, Core.Schemas.Countries
    belongs_to :charitable_organization, Core.Schemas.CharitableOrganization

    timestamps()
  end

  @doc false
  def changeset(donations, attrs) do
    donations
    |> cast(attrs, [
      :title,
      :slug,
      :description,
      :amount,
      :status,
      :valid_from,
      :valid_to,
      :charitable_organization_id,
      :country_id
    ])
    |> validate_required([:title, :slug, :description, :amount, :status, :valid_from, :valid_to])
  end
end
