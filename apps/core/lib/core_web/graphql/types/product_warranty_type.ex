defmodule CoreWeb.GraphQL.Types.ProductWarrantyType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :product_warranty_type do
    field :id, :integer
    field :warranty_id, :integer
    field :user_id, :integer
    field :product_name, :string
    field :product_description, :string
    field :product_model, :string
    field :product_code, :string
    field :serial_number, :string
    field :product_purchase_date, :string
    field :product_made_in_country, :string
    field :seller_name, :string
    field :seller_address, :string
    field :seller_location, :json
    field :seller_phone, :string
    field :seller_agent_name, :string
    field :seller_contact_email, :string
    field :warranty_type, :string
    field :warranty_provider, :string
    field :warranty_begin_date, :string
    field :warranty_period, :integer
    field :warranty_period_unit, :string
    field :warranty_end_date, :string
    field :proof_of_purchase, list_of(:string)
    field :proof_of_installments, list_of(:string)
    field :reference_url, :string
    field :type, :product_types, resolve: assoc(:type)
    field :manufacturer, :manufacturer_names, resolve: assoc(:manufacturer)
    field :status, :string
  end

  object :product_types do
    field :id, :string
    field :description, :string
  end

  object :manufacturer_names do
    field :id, :string
    field :description, :string
  end

  object :paginate_manufacturer_names do
    field :page_number, :integer
    field :page_size, :integer
    field :total_entries, :integer
    field :total_pages, :integer
    field :entries, list_of(:manufacturer_names)
  end

  input_object :manufacturer_names_input_type do
    field :page_number, :integer
    field :page_size, :integer
    field :search, :string
  end

  input_object :product_warranty_input_type do
    field :warranty_id, non_null(:integer)
    field :product_name, non_null(:string)
    field :product_description, :string
    field :product_model, non_null(:string)
    field :product_code, non_null(:string)
    field :serial_number, non_null(:string)
    field :product_purchase_date, non_null(:datetime)
    field :product_made_in_country, :string
    field :seller_name, non_null(:string)
    field :seller_address, :string
    field :seller_location, :seller_location_type
    field :seller_phone, :string
    field :seller_agent_name, :string
    field :seller_contact_email, :string
    field :warranty_type, non_null(:warranty_type)
    field :warranty_provider, :string
    field :warranty_begin_date, non_null(:datetime)
    field :warranty_period, non_null(:integer)
    field :warranty_period_unit, :period_unit_type
    field :proof_of_purchase, list_of(non_null(:image_input_type))
    field :proof_of_installments, list_of(:image_input_type)
    field :reference_url, :string
    field :type_id, non_null(:string)
    field :manufacturer_id, non_null(:string)
    field :status, non_null(:status_type)
  end

  input_object :update_product_warranty_input_type do
    field :id, non_null(:integer)
    field :warranty_id, :integer
    field :product_name, :string
    field :product_description, :string
    field :product_model, :string
    field :product_code, :string
    field :serial_number, :string
    field :product_purchase_date, :datetime
    field :product_made_in_country, :string
    field :seller_name, :string
    field :seller_address, :string
    field :seller_location, :seller_location_type
    field :seller_phone, :string
    field :seller_agent_name, :string
    field :seller_contact_email, :string
    field :warranty_type, :warranty_type
    field :warranty_provider, :string
    field :warranty_begin_date, :datetime
    field :warranty_period, :integer
    field :warranty_period_unit, :period_unit_type
    field :proof_of_purchase, list_of(:image_input_type)
    field :proof_of_installments, :image_input_type
    field :reference_url, :string
    field :type_id, :integer
    field :manufacturer_id, :integer
    field :status, :status_type
  end

  input_object :delete_product_warranty_input_type do
    field :id, non_null(:integer)
  end

  input_object :seller_location_type do
    field :lat, :float
    field :long, :float
  end

  enum :warranty_type do
    value(:manufacture_warranty)
    value(:extended_warranty)
  end

  enum :period_unit_type do
    value(:days)
    value(:months)
    value(:years)
  end

  enum :status_type do
    value(:active)
    value(:inactive)
  end

  input_object :image_input_type do
    field :orignal, :string
    field :thumb, :string
  end
end
