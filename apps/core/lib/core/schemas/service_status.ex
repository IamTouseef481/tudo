defmodule Core.Schemas.ServiceStatus do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "service_statuses" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(service_status, attrs) do
    service_status
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
