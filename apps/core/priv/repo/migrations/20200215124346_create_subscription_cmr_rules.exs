defmodule Core.Repo.Migrations.CreateCMRSubscriptionRules do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:subscription_cmr_rules) do
      add :package_id, :string
      add :package_name, :string
      add :package_monthly_price, :float
      add :package_annual_price, :float
      add :package_validity, :string
      add :service_appointments, :string
      add :data_limit, :integer, default: 0
      add :data_retention, :integer, default: 0
      add :tudo_portion_of_consumer_tip, :integer
      add :consolidated_calendar, :boolean, default: false, null: false
      add :tasks_events, :boolean, default: false, null: false
      add :consumer_family_member, :boolean, default: false, null: false
      add :deals, :boolean, default: false, null: false
      add :job_search_apply, :boolean, default: false, null: false
      add :my_net, :boolean, default: false, null: false
      add :consumer_private_messaging, :boolean, default: false, null: false
      add :n_ter, :boolean, default: false, null: false
      add :business_verification, :boolean, default: false, null: false
      add :bus_net, :boolean, default: false, null: false
      add :business_private_messaging, :boolean, default: false, null: false
      add :branch_offices, :boolean, default: false, null: false
      add :employees, :boolean, default: false, null: false
      add :tenant_business_providers, :boolean, default: false, null: false
      add :promotions, :boolean, default: false, null: false
      add :job_postings, :integer, default: 0
      add :reports_period, :integer, default: 0
      add :payment_with_applied_fee, :boolean, default: false, null: false
      add :show_adds, :boolean, default: false, null: false
      add :data_privacy, :boolean, default: false, null: false
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create index(:subscription_cmr_rules, [:country_id])
  end
end
