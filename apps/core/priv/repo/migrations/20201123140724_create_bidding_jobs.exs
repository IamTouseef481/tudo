defmodule Core.Repo.Migrations.CreateBiddingJobs do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:bidding_jobs) do
      add :title, :string
      add :description, :text
      add :gallery, {:array, :map}
      add :country_service_id, :integer
      add :location_dest, :geometry
      add :job_address, :string
      add :arrive_at, :utc_datetime
      add :expected_work_duration, :time
      add :posted_at, :utc_datetime
      add :accepted, :boolean, default: false, null: false
      add :expired, :boolean, default: false, null: false
      add :cmr_id, :integer
      add :questions, {:array, :string}
      add :dynamic_fields, :map
      add :service_type_id, references(:service_types, type: :varchar, on_delete: :nothing)

      timestamps()
    end

    create index(:bidding_jobs, [:service_type_id])
  end
end
