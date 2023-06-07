defmodule Core.Repo.Migrations.CreateProductWarranties do
  use Ecto.Migration

  def change do
    create table(:product_warranties) do
      add :warranty_id, :integer
      add :product_name, :string
      add :product_description, :string
      add :product_model, :string
      add :product_code, :string
      add :serial_number, :string
      add :product_purchase_date, :utc_datetime
      add :product_made_in_country, :string
      add :seller_name, :string
      add :seller_address, :string
      add :seller_location, :geometry
      add :seller_phone, :string
      add :seller_agent_name, :string
      add :seller_contact_email, :string
      add :warranty_type, :string
      add :warranty_provider, :string
      add :warranty_begin_date, :utc_datetime
      add :warranty_period, :integer
      add :warranty_period_unit, :string
      add :warranty_end_date, :utc_datetime
      add :proof_of_purchase, {:array, :map}
      add :proof_of_installments, {:array, :map}
      add :reference_url, :text
      add :status, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :type_id, references(:product_types, on_delete: :nothing, type: :string)
      add :manufacturer_id, references(:product_manufacturers, on_delete: :nothing, type: :string)

      timestamps()
    end
  end
end
