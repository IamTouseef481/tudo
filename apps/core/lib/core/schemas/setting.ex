defmodule Core.Schemas.Setting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field :fields, :map
    field :slug, :string
    field :title, :string
    field :type, :string
    belongs_to :branch, Core.Schemas.Branch
    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:branch_id, :title, :slug, :type, :fields])
    |> validate_required([:branch_id, :title, :slug, :type, :fields])
  end
end
