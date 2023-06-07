defmodule Core.Repo.Migrations.CreateJobRequests do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:job_requests) do
      add :cost, :float
      add :title, :string
      add :description, :string
      add :arrive_at, :utc_datetime
      add :expected_work_duration, :time
      add :bsp_current_location, :geometry
      add :location_dest, :geometry
      add :location_src, :geometry
      add :cmr_id, references(:users, on_delete: :nothing)
      add :lead_id, references(:leads, on_delete: :nothing)
      add :employee_id, references(:employees, on_delete: :nothing)
      add :branch_service_id, references(:branch_services, on_delete: :nothing)
      add :job_status_id, references(:job_statuses, type: :varchar, on_delete: :nothing)

      timestamps()
    end

    create index(:job_requests, [:cmr_id])
    create index(:job_requests, [:lead_id])
    create index(:job_requests, [:employee_id])
    create index(:job_requests, [:job_status_id])
    create index(:job_requests, [:branch_service_id])
  end
end
