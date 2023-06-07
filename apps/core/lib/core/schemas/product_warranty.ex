defmodule Core.Schemas.ProductWarranty do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  alias Core.Schemas.{ProductType, ProductManufacturer}

  schema "product_warranties" do
    field :warranty_id, :integer
    field :user_id, :integer
    field :product_name, :string
    field :product_description, :string
    field :product_model, :string
    field :product_code, :string
    field :serial_number, :string
    field :product_purchase_date, :utc_datetime
    field :product_made_in_country, :string
    field :seller_name, :string
    field :seller_address, :string
    field :seller_location, Geo.PostGIS.Geometry
    field :seller_phone, :string
    field :seller_agent_name, :string
    field :seller_contact_email, :string
    field :warranty_type, :string
    field :warranty_provider, :string
    field :warranty_begin_date, :utc_datetime
    field :warranty_period, :integer
    field :warranty_period_unit, :string
    field :warranty_end_date, :utc_datetime
    field :proof_of_purchase, {:array, :map}
    field :proof_of_installments, {:array, :map}
    field :reference_url, :string
    field :status, :string

    belongs_to :type, ProductType, type: :string
    belongs_to :manufacturer, ProductManufacturer, type: :string

    timestamps()
  end

  @doc false
  def changeset(product_warranty, attrs) do
    product_warranty
    |> cast(attrs, [
      :warranty_id,
      :user_id,
      :product_name,
      :product_description,
      :product_model,
      :product_code,
      :serial_number,
      :product_purchase_date,
      :product_made_in_country,
      :seller_name,
      :seller_address,
      :seller_location,
      :seller_phone,
      :seller_agent_name,
      :seller_contact_email,
      :warranty_type,
      :warranty_provider,
      :warranty_period,
      :warranty_period_unit,
      :warranty_end_date,
      :proof_of_purchase,
      :proof_of_installments,
      :reference_url,
      :status,
      :type_id,
      :manufacturer_id,
      :warranty_begin_date
    ])
    |> validate_required([
      :warranty_id,
      :user_id,
      :product_name,
      :product_description,
      :product_model,
      :product_code,
      :serial_number,
      :product_purchase_date,
      :product_made_in_country,
      :seller_name,
      :warranty_type,
      :warranty_period_unit,
      :warranty_end_date,
      :proof_of_purchase,
      :status,
      :type_id,
      :manufacturer_id,
      :warranty_begin_date,
      :warranty_period
    ])
  end
end
