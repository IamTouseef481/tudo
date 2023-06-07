defmodule Core.Schemas.EmailCategory do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "email_categories" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(email_category, attrs) do
    email_category
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
