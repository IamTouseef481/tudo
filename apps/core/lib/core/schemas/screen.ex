defmodule Core.Schemas.Screen do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "screens" do
    field :description, :string
    field :id, :string, primary_key: true
  end

  @doc false
  def changeset(screen, attrs) do
    screen
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
