defmodule Core.Schemas.Application do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "applications" do
    field :id, :string, primary_key: true
    field :name, :string
  end

  @doc false
  def changeset(application, attrs) do
    application
    |> cast(attrs, [
      :id,
      :name
    ])
    |> validate_required([:id, :name])
  end
end
