defmodule Core.Schemas.Job do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{JobCategory, JobStatus, GoogleCalender, JobNote}

  @validate_for_insert [
    :title,
    :service_type_id,
    :is_reoccurring,
    :cost,
    :arrive_at,
    :expected_work_duration,
    :job_category_id,
    :job_status_id
  ]
  @all_fields [
    :service_type_id,
    :day_light,
    :job_category_id,
    :is_reoccurring,
    :address_id,
    :branch_service_id,
    :branch_service_ids,
    :employee_id,
    :promotion_id,
    :bidding_proposal_id,
    :chat_group_id,
    :cancelled_by,
    :deleted_by,
    :approved_by,
    :inserted_by,
    :updated_by,
    :parent_service_id,
    :job_status_id,
    :job_cmr_status_id,
    :job_bsp_status_id,
    :title,
    :description,
    :gallery,
    :initial_cost,
    :cost,
    :revise_cost,
    :cost_at_working,
    :cost_at_complete,
    :arrive_at,
    :expected_work_duration,
    :waiting_ewd,
    :waiting_arrive_at,
    :reason_for_time_change,
    :time_change_request_by,
    :old_job_status_id,
    :work_duration_at_working,
    :location_src,
    :location_dest,
    :location_src_zone_id,
    :location_dest_zone_id,
    :service_params,
    :cmr_to_bsp_rating,
    :cmr_to_bsp_rating_friendly,
    :cmr_to_bsp_rating_professional,
    :cmr_to_bsp_rating_communication,
    :bsp_to_cmr_rating_friendly,
    :bsp_to_cmr_rating_professional,
    :bsp_to_cmr_rating_communication,
    :cmr_to_bsp_comments,
    :bsp_to_cmr_rating,
    :bsp_to_cmr_comments,
    :location_src_name,
    :basic_fee,
    :item_fee,
    :fee,
    :dynamic_fields,
    :confirmed_at,
    :rejected_at,
    :called_at,
    :started_working_at,
    :completed_at,
    :cancelled_at,
    :cancel_reason,
    :dispute_reason,
    :history,
    :deleted_at,
    :approved_at,
    :update_status_by,
    :ticket_no,
    :job_address,
    :auto_cancel_process_id,
    :on_behalf_cmr,
    :picked_at,
    :will_pick_at
  ]

  schema "jobs" do
    field :deleted_at, :utc_datetime
    field :location_src, Geo.PostGIS.Geometry
    field :location_dest, Geo.PostGIS.Geometry
    field :service_params, :map
    field :dynamic_fields, :map
    field :history, :map
    field :cost_at_working, :float
    field :started_working_at, :utc_datetime
    field :cancelled_at, :utc_datetime
    field :item_fee, :float
    field :approved_at, :utc_datetime
    field :location_src_zone_id, :integer
    field :cancel_reason, :string
    field :dispute_reason, :string
    field :cost_at_complete, :float
    field :location_dest_zone_id, :integer
    field :fee, :float
    field :arrive_at, :utc_datetime
    field :work_duration_at_working, :time
    field :completed_at, :utc_datetime
    field :called_at, :utc_datetime
    field :basic_fee, :float
    field :description, :string
    field :cmr_to_bsp_rating, :float
    field :cmr_to_bsp_rating_friendly, :float
    field :cmr_to_bsp_rating_professional, :float
    field :cmr_to_bsp_rating_communication, :float
    field :bsp_to_cmr_rating, :float
    field :bsp_to_cmr_rating_friendly, :float
    field :bsp_to_cmr_rating_professional, :float
    field :bsp_to_cmr_rating_communication, :float
    field :cmr_to_bsp_comments, :map
    field :bsp_to_cmr_comments, :map
    field :location_src_name, :string
    field :title, :string
    field :confirmed_at, :utc_datetime
    field :initial_cost, :float
    field :gallery, {:array, :map}
    field :cost, :float
    field :revise_cost, :boolean
    field :on_behalf_cmr, :boolean, default: false
    field :is_reoccurring, :boolean, default: false
    field :rejected_at, :utc_datetime
    field :expected_work_duration, :time
    field :waiting_ewd, :time
    field :waiting_arrive_at, :utc_datetime
    field :picked_at, :utc_datetime
    field :will_pick_at, :utc_datetime
    field :reason_for_time_change, :string
    field :time_change_request_by, :string
    field :old_job_status_id, :string
    field :parent_service_id, :integer
    field :employee_id, :integer
    field :promotion_id, :integer
    field :service_type_id, :string
    field :day_light, :string
    field :auto_cancel_process_id, :string
    field :address_id, :integer
    field :branch_service_id, :integer
    field :branch_service_ids, {:array, :integer}
    field :ticket_no, :integer
    field :cancelled_by, :integer
    field :deleted_by, :integer
    field :approved_by, :integer
    field :inserted_by, :integer
    field :updated_by, :integer
    field :update_status_by, :string
    field :job_address, :string
    field :chat_group_id, :integer
    field :bidding_proposal_id, :integer
    belongs_to :job_category, JobCategory, type: :string
    belongs_to :job_status, JobStatus, type: :string
    belongs_to :job_cmr_status, JobStatus, type: :string
    belongs_to :job_bsp_status, JobStatus, type: :string
    has_many :job_google_calender, GoogleCalender
    has_many :job_notes, JobNote

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, @all_fields)
    |> foreign_key_constraint(:job_cmr_status_id)
    |> foreign_key_constraint(:job_bsp_status_id)
    |> foreign_key_constraint(:job_status_id)
    |> validate_required(@validate_for_insert)
  end

  def get_schedule(job) do
    location_src =
      case job.location_src do
        %{coordinates: {src_long, src_lat}} -> %{lat: src_lat, long: src_long}
        _ -> nil
      end

    location_dest =
      case job.location_dest do
        %{coordinates: {dest_long, dest_lat}} -> %{lat: dest_lat, long: dest_long}
        _ -> nil
      end

    %{
      id: job.id,
      deleted_at: job.deleted_at,
      location_src: location_src,
      location_dest: location_dest,
      service_params: job.service_params,
      dynamic_fields: job.dynamic_fields,
      cost_at_working: job.cost_at_working,
      started_working_at: job.started_working_at,
      item_fee: job.item_fee,
      cancelled_at: job.cancelled_at,
      approved_at: job.approved_at,
      location_src_zone_id: job.location_src_zone_id,
      cancel_reason: job.cancel_reason,
      dispute_reason: job.dispute_reason,
      cost_at_complete: job.cost_at_complete,
      location_dest_zone_id: job.location_dest_zone_id,
      fee: job.fee,
      arrive_at: job.arrive_at,
      picked_at: Map.get(job, :picked_at),
      will_pick_at: Map.get(job, :will_pick_at),
      work_duration_at_working: job.work_duration_at_working,
      completed_at: job.completed_at,
      called_at: job.called_at,
      basic_fee: job.basic_fee,
      description: job.description,
      cmr_to_bsp_rating: job.cmr_to_bsp_rating,
      cmr_to_bsp_rating_friendly: job.cmr_to_bsp_rating_friendly,
      cmr_to_bsp_rating_professional: job.cmr_to_bsp_rating_professional,
      cmr_to_bsp_rating_communication: job.cmr_to_bsp_rating_communication,
      bsp_to_cmr_rating: job.bsp_to_cmr_rating,
      bsp_to_cmr_rating_friendly: job.bsp_to_cmr_rating_friendly,
      bsp_to_cmr_rating_professional: job.bsp_to_cmr_rating_professional,
      bsp_to_cmr_rating_communication: job.bsp_to_cmr_rating_communication,
      cmr_to_bsp_comments: job.cmr_to_bsp_comments,
      bsp_to_cmr_comments: job.bsp_to_cmr_comments,
      location_src_name: job.location_src_name,
      title: job.title,
      confirmed_at: job.confirmed_at,
      initial_cost: job.initial_cost,
      gallery: job.gallery,
      cost: job.cost,
      revise_cost: job.revise_cost,
      rejected_at: job.rejected_at,
      expected_work_duration: job.expected_work_duration,
      waiting_ewd: job.waiting_ewd,
      waiting_arrive_at: job.waiting_arrive_at,
      reason_for_time_change: job.reason_for_time_change,
      time_change_request_by: job.time_change_request_by,
      old_job_status_id: job.old_job_status_id,
      parent_service_id: job.parent_service_id,
      employee_id: job.employee_id,
      promotion_id: job.promotion_id,
      service_type_id: job.service_type_id,
      day_light: job.day_light,
      address_id: job.address_id,
      branch_service_id: job.branch_service_id,
      branch_service_ids: job.branch_service_ids,
      ticket_no: job.ticket_no,
      cancelled_by: job.cancelled_by,
      deleted_by: job.deleted_by,
      approved_by: job.approved_by,
      inserted_by: job.inserted_by,
      updated_by: job.updated_by,
      update_status_by: job.update_status_by,
      job_address: job.job_address,
      is_reoccurring: job.is_reoccurring,
      chat_group_id: job.chat_group_id,
      bidding_proposal_id: job.bidding_proposal_id,
      job_status_id: job.job_status_id,
      job_cmr_status_id: job.job_cmr_status_id,
      job_bsp_status_id: job.job_bsp_status_id,
      job_category_id: job.job_category_id
    }
  end
end
