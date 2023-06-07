defmodule TudoChat.Groups.GroupStatus do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "group_statuses" do
    field :description, :string
    field :id, :string, primary_key: true
  end

  @doc false
  def changeset(group_status, attrs) do
    group_status
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
