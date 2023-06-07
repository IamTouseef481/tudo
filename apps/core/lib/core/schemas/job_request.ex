defmodule Core.Schemas.JobRequest do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{BranchService, JobStatus, Lead, User}

  @validate_for_insert [
    :cmr_id,
    :lead_id,
    :bsp_current_location,
    :location_dest,
    :location_src,
    :branch_service_id,
    :expected_work_duration,
    :arrive_at,
    :job_status_id,
    :employee_id,
    :cost
  ]
  @all_fields [
    :cmr_id,
    :lead_id,
    :bsp_current_location,
    :location_dest,
    :location_src,
    :branch_service_id,
    :expected_work_duration,
    :arrive_at,
    :job_status_id,
    :employee_id,
    :cost,
    :title,
    :description
  ]

  schema "job_requests" do
    field :description, :string
    field :title, :string
    field :cost, :float
    field :arrive_at, :utc_datetime
    field :expected_work_duration, :time
    field :location_dest, Geo.PostGIS.Geometry
    field :location_src, Geo.PostGIS.Geometry
    field :bsp_current_location, Geo.PostGIS.Geometry
    belongs_to :cmr, User
    belongs_to :lead, Lead
    belongs_to :branch_service, BranchService
    belongs_to :employee, Core.Schemas.Employee
    belongs_to :job_status, JobStatus, type: :string

    timestamps()
  end

  @doc false
  def changeset(job_request, attrs) do
    job_request
    |> cast(attrs, @all_fields)
    |> foreign_key_constraint(:branch_id)
    |> validate_required(@validate_for_insert)
  end
end
