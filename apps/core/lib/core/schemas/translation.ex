defmodule Core.Schemas.Translation do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "translations" do
    field :field_id, :integer
    field :language, :string
    field :slug, :string
    field :translation, :string

    timestamps()
  end

  @doc false
  def changeset(translation, attrs) do
    translation
    |> cast(attrs, [:slug, :language, :field_id, :translation])
    |> validate_required([:slug, :language, :field_id, :translation])
  end
end
