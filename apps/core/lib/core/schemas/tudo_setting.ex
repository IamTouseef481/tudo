defmodule Core.Schemas.TudoSetting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "tudo_settings" do
    field :is_active, :boolean, default: false
    field :slug, :string
    field :title, :string
    field :unit, :string
    field :value, :float
    belongs_to :country, Core.Schemas.Countries

    timestamps()
  end

  @doc false
  def changeset(tudo_setting, attrs) do
    tudo_setting
    |> cast(attrs, [:title, :slug, :value, :unit, :is_active, :country_id])
    |> validate_required([:slug, :country_id])
  end
end
