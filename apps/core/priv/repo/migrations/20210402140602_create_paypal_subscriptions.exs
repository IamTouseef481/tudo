defmodule Core.Repo.Migrations.CreatePaypalSubscriptions do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:paypal_subscriptions) do
      add :paypal_subscription_id, :string
      add :annual, :boolean, default: false, null: false
      add :start_date, :date
      add :expiry_date, :date
      add :slug, :string
      add :name, :string
      add :monthly_price, :float
      add :annual_price, :float
      add :currency, :string
      add :active, :boolean, default: false, null: false
      add :plan_discount, :map
      add :cmr_walk_in_appointments, :map
      add :cmr_home_service_appointments, :map
      add :cmr_on_demand_appointments, :map
      add :cmr_data_limit, :map
      add :cmr_data_retention, :map
      add :cmr_calendar, :map
      add :cmr_tasks_events, :map
      add :cmr_my_net, :map
      add :cmr_nter, :map
      add :cmr_family, :map
      add :cmr_deals, :map
      add :cmr_jobs_search, :map
      add :cmr_reports, :map
      add :bsp_walk_in_appointments, :map
      add :bsp_home_service_appointments, :map
      add :bsp_on_demand_appointments, :map
      add :bsp_data_limit, :map
      add :bsp_data_retention, :map
      add :bsp_calendar, :map
      add :bsp_bus_net, :map
      add :bsp_nter, :map
      add :promotions, :map
      add :leads, :map
      add :prospects, :map
      add :job_postings, :map
      add :employees, :map
      add :gratuity, :map
      add :marketing, :map
      add :branches, :map
      add :advance_reports, :map
      add :tenant, :map
      add :events, :map
      add :bid_proposal, :map
      add :e_commerce, :map
      add :warehouse, :map
      add :employee_center, :map
      add :risk_managemment, :map
      add :time_managemment, :map
      add :compensation, :map
      add :recruitment, :map
      add :shopping, :map
      add :accounting, :map
      add :budget_planning, :map
      add :finance_management, :map
      add :supply_chain, :map
      add :restaurant, :map
      add :transportation, :map
      add :event_management, :map
      add :custom_portals, :map
      add :add_on1, :map
      add :add_on2, :map
      add :add_on3, :map
      add :add_on4, :map
      add :add_on5, :map
      add :add_on6, :map
      add :add_on7, :map
      add :add_on8, :map
      add :add_on9, :map
      add :add_on10, :map
      add :add_on11, :map
      add :add_on12, :map
      add :add_on13, :map
      add :add_on14, :map
      add :add_on15, :map
      add :add_on16, :map
      add :add_on17, :map
      add :add_on18, :map
      add :add_on19, :map
      add :add_on20, :map
      add :country_id, references(:countries, on_delete: :nothing)
      add :subscription_plan_id, references(:paypal_subscription_plans, on_delete: :nothing)

      add :status_id,
          references(:brain_tree_subscription_statuses, type: :varchar, on_delete: :nothing)

      add :business_id, references(:businesses, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:paypal_subscriptions, [:status_id])
    create index(:paypal_subscriptions, [:business_id])
    create index(:paypal_subscriptions, [:user_id])
    create index(:paypal_subscriptions, [:subscription_plan_id])
  end
end
