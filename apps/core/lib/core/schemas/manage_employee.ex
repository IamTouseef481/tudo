defmodule Core.Schemas.ManageEmployee do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "manage_employees" do
    belongs_to :employee, Core.Schemas.Employee
    belongs_to :manager, Core.Schemas.Employee

    timestamps()
  end

  @doc false
  def changeset(manage_employee, attrs) do
    manage_employee
    |> cast(attrs, [:manager_id, :employee_id])
    |> validate_required([:manager_id, :employee_id])
  end
end
