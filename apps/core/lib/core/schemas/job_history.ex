defmodule Core.Schemas.JobHistory do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{Job, JobStatus}

  schema "job_history" do
    field :inserted_by, :integer
    field :invoice_id, :integer
    field :payment_id, :integer
    field :reason, :string
    field :updated_by, :integer
    field :user_role, :string
    field :created_at, :utc_datetime
    belongs_to :job, Job
    belongs_to :job_status, JobStatus, type: :string
    belongs_to :job_cmr_status, JobStatus, type: :string
    belongs_to :job_bsp_status, JobStatus, type: :string

    timestamps()
  end

  @doc false
  def changeset(job_history, attrs) do
    job_history
    |> cast(attrs, [
      :reason,
      :inserted_by,
      :updated_by,
      :user_role,
      :invoice_id,
      :payment_id,
      :created_at,
      :job_id,
      :job_status_id,
      :job_cmr_status_id,
      :job_bsp_status_id
    ])
    |> validate_required([:job_id])
  end
end
