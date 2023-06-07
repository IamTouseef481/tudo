defmodule TudoChat.Groups.GroupType do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "group_types" do
    field :description, :string
    field :id, :string, primary_key: true
  end

  @doc false
  def changeset(group_type, attrs) do
    group_type
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
    |> unique_constraint(:id)
  end
end
