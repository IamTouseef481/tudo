defmodule Core.Repo.Migrations.CreateJobHistory do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:job_history) do
      add :reason, :text
      add :inserted_by, :integer
      add :updated_by, :integer
      add :user_role, :string
      add :invoice_id, :integer
      add :payment_id, :integer
      add :created_at, :utc_datetime
      add :job_id, references(:jobs, on_delete: :nothing)
      add :job_status_id, references(:job_statuses, type: :varchar, on_delete: :nothing)
      add :job_cmr_status_id, references(:job_statuses, type: :varchar, on_delete: :nothing)
      add :job_bsp_status_id, references(:job_statuses, type: :varchar, on_delete: :nothing)

      timestamps()
    end

    create index(:job_history, [:job_id])
    create index(:job_history, [:job_status_id])
    create index(:job_history, [:job_cmr_status_id])
    create index(:job_history, [:job_bsp_status_id])
  end
end
