defmodule Core.Repo.Migrations.CreateTableJobs do
  @moduledoc false
  use Ecto.Migration

  @table :jobs
  def change do
    create table(@table) do
      add :title, :string
      add :description, :text
      add :gallery, {:array, :map}
      add :employee_id, :integer
      add :service_type_id, :string
      add :day_light, :string
      #      add :parent_service_id, references(:services, on_delete: :nothing)
      add :parent_service_id, :integer
      add :ticket_no, :integer
      add :initial_cost, :float
      add :cost, :float
      add :revise_cost, :boolean
      add :cost_at_working, :float
      add :cost_at_complete, :float
      add :arrive_at, :utc_datetime
      add :expected_work_duration, :time
      add :waiting_ewd, :time
      add :waiting_arrive_at, :utc_datetime
      add :time_change_request_by, :string
      add :reason_for_time_change, :string
      add :old_job_status_id, :string
      add :work_duration_at_working, :time
      add :location_src, :geometry
      add :location_dest, :geometry
      add :location_src_zone_id, :integer
      add :location_dest_zone_id, :integer
      add :service_params, :map
      add :cmr_to_bsp_rating, :float
      add :cmr_to_bsp_rating_friendly, :float
      add :cmr_to_bsp_rating_professional, :float
      add :cmr_to_bsp_rating_communication, :float
      add :bsp_to_cmr_rating, :float
      add :bsp_to_cmr_rating_friendly, :float
      add :bsp_to_cmr_rating_professional, :float
      add :bsp_to_cmr_rating_communication, :float
      add :cmr_to_bsp_comments, :map
      add :bsp_to_cmr_comments, :map
      add :location_src_name, :string
      add :basic_fee, :float
      add :item_fee, :float
      add :fee, :float
      add :dynamic_fields, :map
      add :confirmed_at, :utc_datetime
      add :rejected_at, :utc_datetime
      add :called_at, :utc_datetime
      add :started_working_at, :utc_datetime
      add :completed_at, :utc_datetime
      add :cancelled_at, :utc_datetime
      add :cancel_reason, :text
      add :dispute_reason, :text
      add :history, :map
      add :deleted_at, :utc_datetime
      add :approved_at, :utc_datetime
      add :auto_cancel_process_id, :string
      add :address_id, :integer
      add :branch_service_id, :integer
      add :cancelled_by, :integer
      add :deleted_by, :integer
      add :approved_by, :integer
      add :inserted_by, :integer
      add :updated_by, :integer
      add :job_address, :text
      add :promotion_id, :integer
      add :chat_group_id, :integer
      add :bidding_proposal_id, :integer
      add :update_status_by, :string, default: "cmr"
      add :job_category_id, references(:job_categories, type: :varchar, on_delete: :nothing)
      add :job_status_id, references(:job_statuses, type: :varchar, on_delete: :nothing)
      add :job_cmr_status_id, references(:job_statuses, type: :varchar, on_delete: :nothing)
      add :job_bsp_status_id, references(:job_statuses, type: :varchar, on_delete: :nothing)
      #      add :address_id, references(:addresses, on_delete: :nothing)
      #      add :branch_service_id, references(:branch_services, on_delete: :nothing)
      #      add :cancelled_by, references(:employees, on_delete: :nothing)
      #      add :deleted_by, references(:employees, on_delete: :nothing)
      #      add :approved_by, references(:employees, on_delete: :nothing)
      #      add :inserted_by, references(:employees, on_delete: :nothing)
      #      add :updated_by, references(:employees, on_delete: :nothing)

      timestamps()
    end

    create constraint(
             @table,
             "update_status_by_must_be_cmr_bsp_system",
             check: "update_status_by IN ('cmr', 'bsp', 'system')",
             comment: "only these values are allowed"
           )

    #    create index(@table, [:updated_by, :inserted_by, :approved_by, :deleted_by, :cancelled_by, :parent_service_id, :branch_service_id, :job_category_id, :address_id, :job_status_id])
  end
end
