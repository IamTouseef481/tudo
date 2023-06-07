defmodule TudoChatWeb.GraphQL.Types.GroupType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type
  import Ecto.Query
  alias TudoChat.{Accounts.User, Groups.GroupType}

  object :group_type do
    field :id, :id
    field :add_members, :boolean
    field :allow_pvt_message, :boolean
    field :editable, :boolean
    field :public, :boolean
    field :forward, :boolean
    field :name, :string
    field :link, :string
    field :profile_pic, :json
    field :last_message, :message_type
    field :unread_message_count, :integer
    field :reference_id, :integer
    field :service_request_id, :integer
    field :bid_id, :integer
    field :proposal_id, :integer
    field :created_at, :datetime
    field :created_by_id, :integer
    field :branch_id, :integer
    #    field :job_status_id, :string
    field :job, :job_type
    field :group_type, :group_types_type, resolve: assoc(:group_type)
    field :group_status, :group_status_type, resolve: assoc(:group_status)
    field :user_group_members, list_of(:group_member_type)
    field :group_members, list_of(:group_member_type), resolve: assoc(:group_members)
    #    field :created_by, :user_type, resolve: assoc(:created_by)
    #    field :created_by, :user_type do
    #      resolve fn group, _, _ ->
    #        batch({__MODULE__, :users_by_id}, group.created_by_id, fn batch_results ->
    #          {:ok, Map.get(batch_results, group.created_by_id)}
    #        end)
    #      end
    #    end
    #    field :group_type, :group_types_type do
    #      resolve fn group_type, _, _ ->
    #        batch({__MODULE__, :group_types_by_id}, group_type.group_type_id, fn batch_results ->
    #          {:ok, Map.get(batch_results, group_type.group_type_id)}
    #        end)
    #      end
    #    end
  end

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
    field :invoice_amount, :float
    field :parent_service_id, :integer
    field :employee_id, :integer
    field :service_type_id, :string
    field :day_light, :string
    field :address_id, :integer
    #    field :branch_id, :integer
    field :branch_service_id, :integer
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
    #    field :employee, :employee_type
    field :cmr, :user_type
    field :branch, :branch_type
    field :created, :boolean
    field :job_address, :string
    field :promotion_id, :integer
    field :chat_group_id, :integer
    field :bidding_proposal_id, :integer
    #    field :deal, :promotion_type
  end

  object :branch_type do
    field :id, :id
    field :name, :string
    field :description, :string
    field :phone, :string
    field :licence_no, :string
    field :licence_photos, list_of(:json)
    field :licence_expiry_date, :datetime
    field :personal_identification, :json
    field :profile_pictures, list_of(:json)
    field :employees_count, :integer
    #    field :settings, :business_settings_type
    field :est_year, :datetime
    field :address, :json
    field :zone_ids, list_of(:integer)
    field :geo, :json
    field :is_active, :boolean
    field :is_head_office, :boolean
    field :auto_assign, :boolean
    field :rating, :float
    field :rating_count, :integer
    field :custom_license_issuing_authority, :string
    field :general_liability_insured, :boolean
    field :surety_bonded, :boolean
    field :other_details, :string
    # field :business_id, :id
    #    field :business, :business_type, resolve: assoc(:business)
    #    field :business_type, :business_type_type, resolve: assoc(:business_type)
    # field :licence_issuing_authority_id, :id
    #    field :licence_issuing_authority, :licence_issuing_authorities_type,
    #          resolve: assoc(:licence_issuing_authority)
    #    field :employees, list_of(:employee_type), resolve: assoc(:employees)
    #    field :branch_services, list_of(:branch_service_type), resolve: assoc(:branch_services)
    #    field :active_branch_services, list_of(:branch_service_type)
    field :formatted_branch_services, :json
    # field :city_id, :id
    field :owner, :user_type
    #    field :city, :city_type, resolve: assoc(:city)
    field :country_id, :integer
    #    field :country, :country_type, resolve: assoc(:country)
    #    field :status, :user_status_type, resolve: assoc(:status)
  end

  object :group_status_type do
    field :id, :string
    field :description, :string
  end

  input_object :path do
    field :thumb, :string
    field :original, :string
  end

  input_object :group_input_type do
    field :add_members, :boolean
    field :editable, :boolean
    field :forward, :boolean
    field :name, non_null(:string)
    field :rest_profile_pic, :file
    field :service_request_id, :integer
    field :group_type_id, non_null(:string)
    field :group_status_id, :string
    field :public, :boolean
    field :branch_id, :integer
    #    field :proposal_id, :integer
    #    field :profile_pic, :upload
    #    field :reference_id, non_null(:integer)
    #    field :bid_id, :integer
    #    field :allow_pvt_message, non_null(:boolean)
  end

  input_object :group_update_type do
    field :id, non_null(:integer)
    field :group_status_id, :string
    field :rest_profile_pic, :file
    field :public, :boolean
    field :name, :string
    field :add_members, :boolean
    field :editable, :boolean
    field :forward, :boolean
  end

  input_object :group_get_by_type do
    field :branch_id, :integer
  end

  input_object :group_get_type do
    field :group_id, non_null(:integer)
  end

  input_object :group_status_input_type do
    field :id, non_null(:string)
    field :description, :string
  end

  input_object :group_status_update_type do
    field :id, non_null(:string)
    field :description, :string
  end

  input_object :group_status_get_type do
    field :id, non_null(:string)
  end

  def users_by_id(_, ids) do
    User
    |> where([m], m.id in ^ids)
    |> TudoChat.Repo.all(prefix: Triplex.to_prefix("tudo_"))
    |> Map.new(&{&1.id, &1})
  end

  def group_types_by_id(_, ids) do
    GroupType
    |> where([m], m.id in ^ids)
    |> TudoChat.Repo.all(prefix: Triplex.to_prefix("tudo_"))
    |> Map.new(&{&1.id, &1})
  end
end
