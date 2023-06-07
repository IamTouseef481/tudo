defmodule Core.Schemas.Languages do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "languages" do
    field :code, :string
    field :is_active, :boolean, default: false
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(languages, attrs) do
    languages
    |> cast(attrs, [:code, :name, :is_active])
    |> validate_required([:code, :name, :is_active])
  end
end
