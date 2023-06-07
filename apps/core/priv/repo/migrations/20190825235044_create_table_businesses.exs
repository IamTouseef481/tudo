defmodule Core.Repo.Migrations.CreateTableBusinesses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:businesses) do
      add :name, :string
      add :description, :text
      add :phone, :string
      add :agree_to_pay_for_verification, :boolean, default: true, null: false
      add :is_verified, :boolean, default: false, null: false
      add :is_active, :boolean, default: true, null: false
      add :settings, :map
      add :rating, :float, default: 0.0
      add :rating_count, :integer, default: 0
      add :employees_count, :integer, default: 0
      add :terms_and_conditions, {:array, :integer}
      add :profile_pictures, {:array, :map}
      #      add :business_type_id, references(:business_types, on_delete: :nothing)
      add :status_id, references(:user_statuses, type: :varchar, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:businesses, [:user_id, :status_id])
    #    create unique_index(:businesses, [:name])
    #    create unique_index(:businesses, [:name], name: "unique_business_name")
  end
end
