defmodule CoreWeb.GraphQL.Types.BidType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :bidding_job_type do
    field :id, :integer
    field :title, :string
    field :description, :string
    field :gallery, list_of(:json)
    field :country_service_id, :integer
    field :location_dest, :json
    field :job_address, :string
    field :arrive_at, :datetime
    field :expected_work_duration, :time
    field :posted_at, :string
    field :cmr, :user_type
    field :cmr_id, :integer
    field :questions, list_of(:string)
    field :proposals, list_of(:bid_proposal_type)
    field :dynamic_fields, :json
    field :service_type, :service_type_type, resolve: assoc(:service_type)
    # New Field
    field :job_category, :job_category_type, resolve: assoc(:job_category)
  end

  object :bid_proposal_type do
    field :id, :integer
    field :remarks, :string
    field :cost, :float
    field :is_hourly_cost, :boolean
    field :question_answers, :json
    field :chat_group_id, :integer
    field :branch, :branch_type
    field :quotes, :invoice_type
    field :bidding_job, :bidding_job_type, resolve: assoc(:bidding_job)
  end

  input_object :bidding_job_input_type do
    field :title, non_null(:string)
    field :description, :string
    field :gallery, list_of(:file)
    field :country_service_id, non_null(:integer)
    field :service_type_id, non_null(:string)
    field :location_dest, non_null(:geo)
    field :job_address, :string
    field :arrive_at, non_null(:datetime)
    field :expected_work_duration, :time
    field :questions, list_of(:string)
    field :dynamic_fields, :string
    # New field
    field :job_category_id, :string
  end

  input_object :bidding_job_update_type do
    field :id, non_null(:integer)
    field :title, :string
    field :description, :string
    field :gallery, list_of(:file)
    field :country_service_id, :integer
    field :service_type_id, :string
    field :location_dest, :geo
    field :job_address, :string
    field :arrive_at, :datetime
    field :expected_work_duration, :time
    field :questions, list_of(:string)
    field :dynamic_fields, :string
  end

  input_object :bidding_job_get_by_type do
    field :branch_id, :integer
    field :country_service_id, :integer
    field :cmr_id, :integer
  end

  input_object :bidding_job_delete_type do
    field :bidding_job_id, non_null(:integer)
  end

  input_object :bid_proposal_input_type do
    field :bidding_job_id, non_null(:integer)
    field :branch_id, non_null(:integer)
    field :cost, :float
    field :is_hourly_cost, :boolean
    field :remarks, :string
    field :question_answers, :string
  end

  input_object :bid_proposal_update_type do
    field :id, non_null(:integer)
    #    field :cost, :float
    #    field :is_hourly_cost, :boolean
    field :remarks, :string
    field :question_answers, :string
  end

  input_object :bid_proposal_get_type do
    field :branch_id, non_null(:integer)
  end

  input_object :bid_proposal_delete_type do
    field :bidding_job_id, non_null(:integer)
  end
end
