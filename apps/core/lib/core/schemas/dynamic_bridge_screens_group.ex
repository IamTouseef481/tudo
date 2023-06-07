defmodule Core.Schemas.DynamicBridgeScreensGroup do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "bridge_screens_groups" do
    field :dynamic_group_order, :float, default: 0.0
    belongs_to :dynamic_screen, Core.Schemas.DynamicScreen
    belongs_to :dynamic_group, Core.Schemas.DynamicGroup
  end

  @doc false
  def changeset(dynamic_field, attrs) do
    dynamic_field
    |> cast(attrs, [:dynamic_group_id, :dynamic_screen_id, :dynamic_group_order])
    |> validate_required([:dynamic_group_id, :dynamic_screen_id, :dynamic_group_order])
  end
end
