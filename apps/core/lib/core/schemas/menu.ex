defmodule Core.Schemas.Menu do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "menus" do
    field :slug, :string
    field :title, :string
    field :type, :string
    field :description, :string
    field :images, :map
    field :is_active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(menu, attrs) do
    menu
    |> cast(attrs, [:slug, :title, :type, :images, :description, :is_active])
    |> validate_required([:slug, :type, :images, :is_active])
  end
end
