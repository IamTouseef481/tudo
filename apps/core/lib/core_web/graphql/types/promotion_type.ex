defmodule CoreWeb.GraphQL.Types.PromotionType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :promotion_status_type do
    field :id, :string
    field :title, :string
    field :description, :string
  end

  object :promotion_type do
    field :id, :integer
    field :title, :string
    field :description, :string
    field :photos, list_of(:json)
    field :begin_date, :datetime
    field :end_date, :datetime
    field :expiry_count, :integer
    field :max_user_count, :integer
    field :expire_after_amount, :float
    field :valid_after_amount, :float
    field :value, :float
    field :amount, :float
    field :is_combined, :boolean
    field :is_percentage, :boolean
    field :favourite, :boolean
    field :radius, :float
    field :shareable_link, :string
    field :service_ids, list_of(:integer)
    field :services, :json
    field :zone_ids, list_of(:integer)
    field :term_and_condition_ids, list_of(:integer)
    field :discount_type, :dropdown_type, resolve: assoc(:discount_type)
    field :promotion_status, :promotion_status_type, resolve: assoc(:promotion_status)
    field :branch, :branch_type, resolve: assoc(:branch)
    field :promotion_pricing, :promotion_price_type, resolve: assoc(:promotion_pricing)
  end

  object :deal_type do
    field :id, :integer
    field :user, :user_type, resolve: assoc(:user)
    field :promotion, :promotion_type, resolve: assoc(:promotion)
    field :service, :service_type, resolve: assoc(:service)
  end

  object :promotion_price_type do
    field :id, :integer
    field :slug, :string
    field :purchase_new_promotion, :boolean
    field :base_price, :float
    field :broadcast_range, :float
    field :promotion_cost, :float
    field :discounts, list_of(:json)
    field :taxes, list_of(:json)
    field :tax_percentage, :float
    field :discount_percentage, :float
    field :promotion_total_cost, :float
    field :currency_symbol, :string
    field :branch_id, :integer
  end

  object :available_promotions_type do
    field :id, :integer
    field :title, :string
    field :begin_at, :datetime
    field :expire_at, :datetime
    field :used_at, :datetime
    field :broadcast_range, :float
    field :price, :float
    field :additional, :boolean
    field :branch_id, :branch_type, resolve: assoc(:branch)
    field :business_id, :business_type, resolve: assoc(:business)
  end

  input_object :deal_get_type do
    field :country_service_ids, list_of(:integer)
    field :location, non_null(:geo)
    field :favourite, :boolean
    field :service_types, list_of(:string)
    field :sort, :sort_type
    field :user_id, :integer
  end

  input_object :promotion_get_type do
    field :country_service_id, non_null(:integer)
  end

  input_object :get_promotions_by_branch_type do
    field :branch_id, non_null(:integer)
  end

  input_object :promotion_for_innvoice_get_type do
    field :service_id, :integer
    field :job_id, :integer
    #    field :invoice_amount, :integer
  end

  input_object :promotion_input_type do
    field :title, :string
    field :description, :string
    field :photos, list_of(:upload)
    field :rest_photos, list_of(:file)
    field :begin_date, non_null(:datetime)
    field :end_date, non_null(:datetime)
    field :expiry_count, :integer
    field :max_user_count, :integer
    field :expire_after_amount, :float
    field :valid_after_amount, :float
    field :value, :float
    field :is_combined, :boolean
    field :is_percentage, :boolean
    field :favourite, :boolean
    field :service_ids, list_of(:integer)
    field :radius, non_null(:float)
    field :shareable_link, :string
    field :zone_ids, list_of(:integer)
    field :term_and_condition_ids, list_of(:integer)
    field :discount_type_id, :integer
    field :promotion_status_id, non_null(:string)
    field :branch_id, non_null(:integer)
    field :promotion_pricing_id, :integer
  end

  input_object :promotion_update_type do
    field :id, non_null(:integer)
    field :title, :string
    field :description, :string
    field :photos, list_of(:upload)
    field :rest_photos, list_of(:file)
    field :begin_date, :datetime
    field :end_date, :datetime
    field :expiry_count, :integer
    field :expire_after_amount, :float
    field :valid_after_amount, :float
    field :value, :float
    field :is_combined, :boolean
    field :is_percentage, :boolean
    field :favourite, :boolean
    field :service_ids, list_of(:integer)
    field :radius, :float
    field :shareable_link, :string
    field :zone_ids, list_of(:integer)
    field :term_and_condition_ids, list_of(:integer)
    field :discount_type_id, :integer
    field :promotion_status_id, :string
    field :branch_id, :integer
    field :promotion_pricing_id, :integer
  end

  input_object :promotion_status_input_type do
    field :id, non_null(:id)
    field :title, :string
    field :description, :string
  end

  input_object :promotion_status_update_type do
    field :id, non_null(:id)
    field :title, :string
    field :description, :string
  end

  input_object :promotion_status_get_type do
    field :id, non_null(:id)
  end

  input_object :promotion_price_input_type do
    field :branch_id, non_null(:integer)
    field :broadcast_range, non_null(:integer)
    field :slug, non_null(:string)
    field :currency_symbol, :string
    field :purchase_new_promotion, :boolean
  end

  input_object :promotion_price_update_type do
    field :id, non_null(:integer)
    field :branch_id, :integer
    field :broadcast_range, :integer
    field :slug, :string
    field :currency_symbol, :string
    field :purchase_new_promotion, :boolean
  end

  input_object :promotion_price_get_type do
    field :id, non_null(:integer)
  end

  input_object :available_promotions_get_type do
    field :branch_id, :integer
    field :business_id, :integer
    field :available, :boolean
    field :used, :boolean
  end
end
