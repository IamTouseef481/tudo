defmodule CoreWeb.GraphQL.Types.JobType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :job_type do
    field :id, :id
    field :location_src, :json
    field :location_dest, :json
    field :service_params, :json
    field :dynamic_fields, :json
    field :history, :json
    field :cost_at_working, :float
    field :item_fee, :float
    field :location_src_zone_id, :integer
    field :cancel_reason, :string
    field :dispute_reason, :string
    field :cost_at_complete, :float
    field :location_dest_zone_id, :integer
    field :fee, :float
    field :work_duration_at_working, :time
    field :basic_fee, :float
    field :description, :string
    field :meta_message, :string
    field :cmr_to_bsp_rating, :float
    field :cmr_to_bsp_rating_friendly, :float
    field :cmr_to_bsp_rating_professional, :float
    field :cmr_to_bsp_rating_communication, :float
    field :bsp_to_cmr_rating, :float
    field :bsp_to_cmr_rating_friendly, :float
    field :bsp_to_cmr_rating_professional, :float
    field :bsp_to_cmr_rating_communication, :float
    field :cmr_to_bsp_comments, :json
    field :bsp_to_cmr_comments, :json
    field :location_src_name, :string
    field :title, :string
    field :initial_cost, :float
    field :gallery, :json
    field :cost, :float
    field :revise_cost, :boolean
    field :invoice_id, :integer
    field :payment_id, :integer
    field :invoice_amount, :float
    field :cmr_paid_amount, :float
    field :payment_method_id, :string
    field :parent_service_id, :integer
    field :employee_id, :integer
    field :service_type_id, :string
    field :day_light, :string
    field :address_id, :integer
    #    field :branch_id, :integer
    field :branch_service_id, :integer
    field :branch_service_ids, list_of(:integer)
    field :ticket_no, :integer
    field :branch_service, :json
    field :cancelled_by, :integer
    field :deleted_by, :integer
    field :approved_by, :integer
    field :inserted_by, :integer
    field :updated_by, :integer
    field :expected_work_duration, :time
    field :ewd_int, :integer
    field :waiting_ewd, :time
    field :waiting_arrive_at, :datetime
    field :reason_for_time_change, :string
    field :time_change_request_by, :string
    field :old_job_status_id, :string
    field :arrive_at, :datetime
    field :picked_at, :datetime
    field :started_working_at, :datetime
    field :cancelled_at, :datetime
    field :approved_at, :datetime
    field :completed_at, :datetime
    field :called_at, :datetime
    field :confirmed_at, :datetime
    field :rejected_at, :datetime
    field :deleted_at, :datetime
    field :job_category_id, :string
    field :job_status_id, :string
    field :job_cmr_status_id, :string
    field :job_bsp_status_id, :string
    field :employee, :employee_type
    field :cmr, :user_type
    field :branch, :branch_type
    field :branches, list_of(:branch_type)
    field :created, :boolean
    field :is_reoccurring, :boolean
    field :job_address, :string
    field :promotion_id, :integer
    field :chat_group_id, :integer
    field :bidding_proposal_id, :integer
    field :deal, :promotion_type
    field :job_notes, list_of(:job_note_type)
  end

  object :job_category_type do
    field :id, :string
    field :description, :string
  end

  object :job_status_type do
    field :id, :string
    field :description, :string
  end

  object :job_history_type do
    field :id, :integer
    field :reason, :string
    field :inserted_by, :user_type
    field :updated_by, :user_type
    field :invoice_id, :integer
    field :payment_id, :integer
    field :user_role, :string
    field :created_at, :datetime
    field :job, :job_type, resolve: assoc(:job)
    field :job_status, :job_status_type, resolve: assoc(:job_status)
    field :job_cmr_status, :job_status_type, resolve: assoc(:job_cmr_status)
    field :job_bsp_status, :job_status_type, resolve: assoc(:job_bsp_status)
  end

  object :rating_type do
    field :ratings, list_of(:rating_reviews_type)
    field :bsp_avg_rating, :float
    field :cmr_avg_rating, :float
    field :branch, :branch_type
    field :user, :user_type
  end

  object :rating_reviews_type do
    field :cmr_to_bsp_rating, :float
    field :cmr_to_bsp_rating_friendly, :float
    field :cmr_to_bsp_rating_professional, :float
    field :cmr_to_bsp_rating_communication, :float
    field :bsp_to_cmr_rating, :float
    field :bsp_to_cmr_rating_friendly, :float
    field :bsp_to_cmr_rating_professional, :float
    field :bsp_to_cmr_rating_communication, :float
    field :cmr_to_bsp_comments, :json
    field :bsp_to_cmr_comments, :json
    field :cmr, :user_type
    field :bsp_name, :string
    field :service_name, :string
    field :rating_date, :string
  end

  object :job_request_type do
    field :description, :string
    field :title, :string
    field :cost, :float
    field :arrive_at, :datetime
    field :picked_at, :datetime
    field :expected_work_duration, :time
    field :location_dest, :json
    field :location_src, :json
    field :bsp_current_location, :json
    field :cmr, :user_type
    field :branch_id, non_null(:integer)
    field :branch_service_id, :integer
    field :job_status, :job_status_type, resolve: assoc(:job_status)
  end

  input_object :reoccurring_type do
    field :repeat_every, :integer
    field :repeat_unit, :repeat_unit_type
    field :re_occurrence, :integer
  end

  enum :repeat_unit_type do
    value(:days)
    value(:weeks)
    value(:months)
    value(:years)
  end

  input_object :job_request_get_by_type do
    field :employee_id, non_null(:id)
    field :job_status_id, :string
  end

  input_object :job_request_get_type do
    field :id, non_null(:id)
  end

  input_object :job_post_onbehalf_input_type do
    field :branch_service_ids, list_of(:integer)
    field :branch_service_id, :integer

    field :is_multiple, :boolean
    field :title, non_null(:string)
    field :phone, non_null(:string)
    field :location_dest, non_null(:geo)
    field :branch_id, non_null(:integer)
    field :arrive_at, non_null(:datetime)
    field :picked_at, non_null(:datetime)
    field :job_category_id, non_null(:string)
    field :job_request_id, :integer
    field :bidding_proposal_id, :integer
    field :description, :string
    field :email, :string
    field :gallery, list_of(:upload)
    field :rest_gallery, list_of(:file)
    field :location_src, :geo
    field :dynamic_fields, :string
    field :cost, :float
    field :is_flexible, :boolean
    field :day_light, :string
    field :approved_by, :integer
    field :expected_work_duration, :time
    field :job_address, :string
    field :profile, :profile_input_type
  end

  input_object :job_input_type do
    field :title, non_null(:string)
    field :location_dest, non_null(:geo)
    field :day_light, non_null(:string)
    field :branch_id, non_null(:integer)
    field :job_category_id, non_null(:string)
    field :arrive_at, non_null(:datetime)

    field :promotion_id, :integer
    field :job_request_id, :integer
    field :bidding_proposal_id, :integer
    field :description, :string
    field :gallery, list_of(:upload)
    field :rest_gallery, list_of(:file)
    field :location_src, :geo
    field :is_reoccurring, :boolean
    field :occurrence, :reoccurring_type
    #    field :service_params, :json
    field :dynamic_fields, :string
    field :location_src_zone_id, :integer
    field :location_dest_zone_id, :integer
    field :basic_fee, :float
    field :item_fee, :float
    field :fee, :float
    field :cost, :float
    field :auto_assign, :boolean
    field :is_flexible, :boolean
    field :is_multiple, :boolean
    #    field :user_id, non_null :integer
    field :location_src_name, :string
    field :service_type_id, :string
    field :service_type_ids, list_of(:string)
    field :service_id, :integer
    field :service_ids, list_of(:integer)
    field :parent_service_id, :integer
    field :branch_service_id, :integer
    field :branch_service_ids, list_of(:integer)
    field :address_id, :integer
    field :cancelled_by, :integer
    field :deleted_by, :integer
    field :approved_by, :integer
    field :inserted_by, :integer
    field :updated_by, :integer
    field :expected_work_duration, :time
    #    field :utc_difference, :integer
    field :started_working_at, :datetime
    field :cancelled_at, :datetime
    field :approved_at, :datetime
    field :completed_at, :datetime
    field :called_at, :datetime
    field :confirmed_at, :datetime
    field :rejected_at, :datetime
    field :deleted_at, :datetime
    field :will_pick_at, :datetime
    field :job_status_id, :string
    field :job_cmr_status_id, :string
    field :job_bsp_status_id, :string
    field :job_address, :string
    #    field :lead_id, :integer
  end

  input_object :job_update_type do
    field :id, non_null(:id)
    field :employee_id, :integer
    #    field :location_src, :geo
    #    field :location_dest, :geo
    #    field :service_params, :json
    field :dynamic_fields, :string
    #    field :history, :json
    field :cmr_to_bsp_rating, :float
    field :cmr_to_bsp_rating_communication, :float
    field :cmr_to_bsp_rating_friendly, :float
    field :cmr_to_bsp_rating_professional, :float
    field :bsp_to_cmr_rating, :float
    field :bsp_to_cmr_rating_friendly, :float
    field :bsp_to_cmr_rating_professional, :float
    field :bsp_to_cmr_rating_communication, :float
    field :cmr_to_bsp_comments, :comment_type
    field :bsp_to_cmr_comments, :comment_type
    field :cost_at_working, :float
    field :item_fee, :float
    #    field :location_src_zone_id, :integer
    field :cancel_reason, :string
    field :dispute_reason, :string
    field :cost_at_complete, :float
    #    field :location_dest_zone_id, :integer
    field :fee, :float
    #    field :work_duration_at_working, :time
    field :basic_fee, :float
    field :description, :string
    field :location_src_name, :string
    field :title, :string
    field :initial_cost, :float
    field :gallery, list_of(:upload)
    field :rest_gallery, list_of(:file)
    field :cost, :float
    field :parent_service_id, :integer
    field :service_type_id, :string
    field :address_id, :integer
    #    field :branch_service_id, :integer
    field :cancelled_by, :integer
    field :deleted_by, :integer
    field :approved_by, :integer
    field :inserted_by, :integer
    field :updated_by, :integer
    #    field :expected_work_duration, :time
    field :waiting_ewd, :time
    field :waiting_arrive_at, :datetime
    field :reason_for_time_change, :string
    field :time_change_request_by, :string
    field :old_job_status_id, :string
    field :approve_time_request, :boolean
    field :arrive_at, :datetime
    field :picked_at, :datetime
    #    field :started_working_at, :datetime
    field :cancelled_at, :datetime
    field :approved_at, :datetime
    field :completed_at, :datetime
    field :called_at, :datetime
    field :confirmed_at, :datetime
    field :rejected_at, :datetime
    field :deleted_at, :datetime
    field :job_category_id, :string
    field :job_status_id, :string
    field :job_cmr_status_id, :string
    field :job_bsp_status_id, :string
    field :bidding_proposal_id, :integer
    field :promotion_id, :integer
    field :job_address, :string
  end

  input_object :job_estimate_revise_type do
    field :job_id, non_null(:integer)
    field :revise_cost, non_null(:boolean)
  end

  input_object :job_estimate_make_type do
    field :job_id, non_null(:integer)
    field :cost, non_null(:float)
    field :fixed_rate, non_null(:boolean)
  end

  input_object :job_estimate_update_type do
    field :job_id, non_null(:integer)
    field :cost, non_null(:float)
  end

  input_object :comment_type do
    field :negative, :string
    field :possitive, :string
  end

  input_object :job_get_cmr_type do
    field :job_cmr_status_id, list_of(:string)
    field :branch_id, :integer
    #    field :page_size, :integer
    #    field :page_number, :integer
  end

  input_object :job_get_bsp_type do
    field :employee_id, :id
    field :job_bsp_status_id, list_of(:string)
    field :user_id, :integer
    #    field :page_size, :integer
    #    field :page_number, :integer
  end

  input_object :job_category_input_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :job_category_update_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :job_category_get_type do
    field :id, non_null(:id)
  end

  input_object :job_status_input_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :job_status_update_type do
    field :id, non_null(:id)
    field :description, :string
  end

  input_object :job_status_get_type do
    field :id, non_null(:id)
  end

  input_object :job_history_get_type do
    field :job_id, non_null(:id)
  end

  input_object :rating_get_type do
    field :user_id, :integer
    field :branch_id, :integer
  end

  input_object :distance_and_time_get_type do
    field :location_dest, :geo
    field :location_src, :geo
  end
end
