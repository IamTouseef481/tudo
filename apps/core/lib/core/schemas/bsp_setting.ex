defmodule Core.Schemas.BSPSetting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "bsp_settings" do
    field :title, :string
    field :slug, :string
    field :type, :string
    field :fields, {:array, :map}
    belongs_to :branch, Core.Schemas.Branch

    timestamps()
  end

  @doc false
  def changeset(bsp_setting, attrs) do
    bsp_setting
    |> cast(attrs, [:title, :slug, :type, :fields, :branch_id])
    |> validate_required([:slug, :fields, :branch_id])
  end
end
