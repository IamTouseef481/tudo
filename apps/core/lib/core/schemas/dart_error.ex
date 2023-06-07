defmodule Core.Schemas.DartError do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "dart_errors" do
    field :level, :string
    field :message, :string
    field :tag, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(dart_error, attrs) do
    dart_error
    |> cast(attrs, [:tag, :level, :message])
    |> validate_required([:tag, :level, :message])
  end
end
