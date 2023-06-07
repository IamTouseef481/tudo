defmodule Core.Schemas.UserStatuses do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "user_statuses" do
    field :id, :string, primary_key: true
    field :title, :string, default: "abc"
    field :description, :string
  end

  @doc false
  def changeset(user_statuses, attrs) do
    user_statuses
    |> cast(attrs, [:id, :title, :description])
    |> validate_required([:id])
  end
end
