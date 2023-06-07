defmodule Core.Schemas.EmployeeRole do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "employee_roles" do
    field :id, :string, primary_key: true
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(employee_role, attrs) do
    employee_role
    |> cast(attrs, [:id, :name])
    |> validate_required([:id, :name])
  end
end
