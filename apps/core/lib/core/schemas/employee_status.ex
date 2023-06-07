defmodule Core.Schemas.EmployeeStatus do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "employee_statuses" do
    field :id, :string, primary_key: true
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(employee_status, attrs) do
    employee_status
    |> cast(attrs, [:id, :name])
    |> validate_required([:id, :name])
  end
end
