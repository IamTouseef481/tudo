defmodule Core.Schemas.Employee do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Schemas.{
    Branch,
    Employee,
    EmployeeRole,
    EmployeeSetting,
    EmployeeStatus,
    EmployeeType,
    PayRate,
    ShiftSchedule,
    User
  }

  schema "employees" do
    field :allowed_annual_ansence_hrs, :integer
    field :contract_begin_date, :utc_datetime
    field :contract_end_date, :utc_datetime
    field :id_documents, :map
    field :pay_scale, :integer
    field :rating, :float
    field :vehicle_details, :map
    field :personal_identification, :map
    field :terms_and_conditions, {:array, :integer}
    field :employee_role_in_org, :string
    field :photos, {:array, :map}
    field :approved_at, :utc_datetime
    field :current_location, Geo.PostGIS.Geometry
    belongs_to :approved_by, Employee
    belongs_to :manager, Employee
    belongs_to :user, User
    belongs_to :branch, Branch
    belongs_to :employee_role, EmployeeRole, type: :string
    belongs_to :employee_status, EmployeeStatus, type: :string
    belongs_to :employee_type, EmployeeType, type: :string
    belongs_to :pay_rate, PayRate, type: :string
    belongs_to :shift_schedule, ShiftSchedule, type: :string
    has_one :employee_setting, EmployeeSetting

    timestamps()
  end

  @all_fields [
    :branch_id,
    :user_id,
    :employee_role_id,
    :employee_status_id,
    :employee_type_id,
    :shift_schedule_id,
    :pay_rate_id,
    :manager_id,
    :contract_begin_date,
    :contract_end_date,
    :vehicle_details,
    :pay_scale,
    :photos,
    :approved_by_id,
    :approved_at,
    :personal_identification,
    :terms_and_conditions,
    :employee_role_in_org,
    :allowed_annual_ansence_hrs,
    :id_documents,
    :rating,
    :current_location
  ]

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, @all_fields)
    |> validate_required([
      :branch_id,
      :employee_role_id,
      :employee_status_id,
      :employee_type_id,
      :shift_schedule_id,
      :pay_rate_id,
      :contract_begin_date,
      :contract_end_date
    ])
  end

  @doc false
  def invite_changeset(employee, attrs) do
    employee
    |> cast(attrs, @all_fields)
    |> validate_required([
      :employee_status_id,
      :photos,
      :personal_identification,
      :terms_and_conditions
    ])
  end
end
