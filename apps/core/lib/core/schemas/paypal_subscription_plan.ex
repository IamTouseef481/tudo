defmodule Core.Schemas.PaypalSubscriptionPlan do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "paypal_subscription_plans" do
    field :name, :string
    field :slug, :string
    field :type, :string
    field :active, :boolean, default: false
    field :annual_price, :float
    field :monthly_price, :float
    field :currency, :string
    field :paypal_plan_id, :string
    field :plan_discount, :map
    field :cmr_walk_in_appointments, :map
    field :cmr_home_service_appointments, :map
    field :cmr_on_demand_appointments, :map
    field :cmr_data_limit, :map
    field :cmr_data_retention, :map
    field :cmr_calendar, :map
    field :cmr_tasks_events, :map
    field :cmr_my_net, :map
    field :cmr_nter, :map
    field :cmr_family, :map
    field :cmr_deals, :map
    field :cmr_jobs_search, :map
    field :cmr_reports, :map
    field :bsp_walk_in_appointments, :map
    field :bsp_home_service_appointments, :map
    field :bsp_on_demand_appointments, :map
    field :bsp_data_limit, :map
    field :bsp_data_retention, :map
    field :bsp_calendar, :map
    field :bsp_bus_net, :map
    field :bsp_nter, :map
    field :promotions, :map
    field :leads, :map
    field :prospects, :map
    field :job_postings, :map
    field :employees, :map
    field :gratuity, :map
    field :marketing, :map
    field :branches, :map
    field :advance_reports, :map
    field :tenant, :map
    field :events, :map
    field :bid_proposal, :map
    field :e_commerce, :map
    field :warehouse, :map
    field :employee_center, :map
    field :risk_managemment, :map
    field :time_managemment, :map
    field :compensation, :map
    field :recruitment, :map
    field :shopping, :map
    field :accounting, :map
    field :budget_planning, :map
    field :finance_management, :map
    field :supply_chain, :map
    field :cashfree_plan_id, :string
    field :restaurant, :map
    field :transportation, :map
    field :event_management, :map
    field :custom_portals, :map
    field :add_on1, :map
    field :add_on2, :map
    field :add_on3, :map
    field :add_on4, :map
    field :add_on5, :map
    field :add_on6, :map
    field :add_on7, :map
    field :add_on8, :map
    field :add_on9, :map
    field :add_on10, :map
    field :add_on11, :map
    field :add_on12, :map
    field :add_on13, :map
    field :add_on14, :map
    field :add_on15, :map
    field :add_on16, :map
    field :add_on17, :map
    field :add_on18, :map
    field :add_on19, :map
    field :add_on20, :map
    belongs_to :country, Core.Schemas.Countries

    timestamps()
  end

  @all_fields [
    :name,
    :slug,
    :type,
    :cashfree_plan_id,
    :active,
    :annual_price,
    :monthly_price,
    :currency,
    :paypal_plan_id,
    :plan_discount,
    :cmr_walk_in_appointments,
    :cmr_home_service_appointments,
    :cmr_on_demand_appointments,
    :cmr_data_limit,
    :cmr_data_retention,
    :cmr_calendar,
    :cmr_tasks_events,
    :cmr_my_net,
    :cmr_nter,
    :cmr_family,
    :cmr_deals,
    :cmr_jobs_search,
    :cmr_reports,
    :bsp_walk_in_appointments,
    :bsp_home_service_appointments,
    :bsp_on_demand_appointments,
    :bsp_data_limit,
    :bsp_data_retention,
    :bsp_calendar,
    :bsp_bus_net,
    :bsp_nter,
    :promotions,
    :leads,
    :prospects,
    :job_postings,
    :employees,
    :gratuity,
    :marketing,
    :branches,
    :advance_reports,
    :tenant,
    :events,
    :bid_proposal,
    :e_commerce,
    :warehouse,
    :employee_center,
    :risk_managemment,
    :time_managemment,
    :compensation,
    :recruitment,
    :shopping,
    :accounting,
    :budget_planning,
    :finance_management,
    :supply_chain,
    :restaurant,
    :transportation,
    :event_management,
    :custom_portals,
    :add_on1,
    :add_on2,
    :add_on3,
    :add_on4,
    :add_on5,
    :add_on6,
    :add_on7,
    :add_on8,
    :add_on9,
    :add_on10,
    :add_on11,
    :add_on12,
    :add_on13,
    :add_on14,
    :add_on15,
    :add_on16,
    :add_on17,
    :add_on18,
    :add_on19,
    :add_on20,
    :country_id
  ]
  @doc false
  def changeset(paypal_subscription_plan, attrs) do
    paypal_subscription_plan
    |> cast(attrs, @all_fields)
    |> validate_required([:slug, :name, :currency, :active, :type, :country_id])
  end
end
