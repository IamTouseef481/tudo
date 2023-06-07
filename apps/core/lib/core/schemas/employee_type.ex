defmodule Core.Schemas.EmployeeType do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "employee_types" do
    field :id, :string, primary_key: true
    field :name, :string
  end

  @doc false
  def changeset(employee_type, attrs) do
    employee_type
    |> cast(attrs, [:id, :name])
    |> validate_required([:id, :name])
  end
end
