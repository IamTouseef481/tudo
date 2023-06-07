defmodule CoreWeb.GraphQL.Types.OrderType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :order_type do
    field :id, :integer
    field :location_dest, :json
    field :location_src, :json
    field :rating, :float
    field :arrive_at, :datetime
    field :picked_at, :datetime
    field :status_id, :string
    field :src_to_dest_distance, :float
    field :cmr_to_bsp_comment, :json
    field :bsp_to_cmr_comment, :json
    field :order_items, list_of(:json)
    field :quotes, list_of(:json)
    field :est_work_duration, :datetime
    field :instruction_to_rider, :string
    field :description, :string
    field :est_delivery_sec, :string
    field :chat_group_id, :integer
    field :user_id, :integer
    field :payment_method, :payment_method_type, resolve: assoc(:payment_method)
  end

  input_object :order_input_type do
    field :location_dest, non_null(:geo)
    field :location_src, :geo
    field :rating, :float
    field :arrive_at, :datetime
    field :picked_at, :datetime
    field :cmr_to_bsp_comment, :comment_type
    field :bsp_to_cmr_comment, :comment_type
    field :est_work_duration, :datetime
    field :instruction_to_rider, :string
    field :payment_method_id, non_null(:string)
    field :chat_group_id, non_null(:integer)
    field :product_detail, list_of(:product_detail_type)
  end

  input_object :update_order_input_type do
    field :id, non_null(:integer)
    field :status_id, :string
    field :est_delivery_sec, :string
  end

  input_object :get_order_input_type do
    field :chat_group_id, :integer
  end

  input_object :product_detail_type do
    field :product_id, non_null(:integer)
    field :quantity, non_null(:integer)
  end
end
