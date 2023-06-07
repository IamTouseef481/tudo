defmodule Core.Schemas.EmployeeService do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{BranchService, Employee}

  schema "employee_services" do
    field :end_date, :utc_datetime
    field :start_date, :utc_datetime
    belongs_to :branch_service, BranchService
    belongs_to :employee, Employee

    timestamps()
  end

  @doc false
  def changeset(employee_service, attrs) do
    employee_service
    |> cast(attrs, [:employee_id, :branch_service_id, :start_date, :end_date])
    |> validate_required([:employee_id, :branch_service_id, :start_date, :end_date])
  end
end
