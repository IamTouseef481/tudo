defmodule Core.Schemas.DynamicScreen do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "dynamic_screens" do
    field :name, :string
    field :description, :string
    field :dynamic_screen_order, :float, default: 0.0
    field :addable, :boolean, default: true
    field :editable, :boolean, default: true
    field :viewable, :boolean, default: true
    field :filterable, :boolean, default: false
    field :help_text, :string
    belongs_to :country_service, Core.Schemas.CountryService
    belongs_to :business, Core.Schemas.Business
    timestamps()
  end

  @doc false
  def changeset(dynamic_field, attrs) do
    dynamic_field
    |> cast(attrs, [
      :name,
      :description,
      :dynamic_screen_order,
      :addable,
      :editable,
      :viewable,
      :filterable,
      :help_text,
      :country_service_id,
      :business_id
    ])
    |> validate_required([:name, :business_id, :country_service_id])
  end
end
