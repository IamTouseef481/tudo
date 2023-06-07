defmodule Core.Schemas.SubscriptionBSPRule do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.Countries

  schema "subscription_bsp_rules" do
    field :package_id, :string
    field :slug, :string
    field :consumer_family_member, :boolean, default: false
    field :data_privacy, :boolean, default: false
    field :n_ter, :boolean, default: false
    field :tenant_business_providers, :integer
    field :data_retention, :integer
    field :time_unit, :string
    field :package_validity, :string
    field :package_monthly_price, :float
    field :package_annual_price, :float
    field :payment_with_applied_fee, :boolean, default: false
    field :allow_additional_employee, :boolean, default: false
    field :allow_additional_branch_office, :boolean, default: false
    field :allow_additional_tenant_business, :boolean, default: false
    field :allow_additional_promotion, :boolean, default: false
    field :allow_additional_job_posting, :boolean, default: false
    field :promotion_validity, :integer
    field :additional_employee_charges, :float
    field :reports_period, :integer
    field :additional_promotion_charges, :float
    field :additional_job_posting_charges, :float
    field :bus_net, :boolean, default: false
    field :deals, :boolean, default: false
    field :employees_count, :integer
    field :business_private_messaging, :boolean, default: false
    field :branch_offices, :integer
    field :consumer_private_messaging, :boolean, default: false
    field :consolidated_calendar, :boolean, default: false
    field :data_limit, :integer
    field :data_unit, :string
    field :business_verification, :boolean, default: false
    field :promotions, :integer
    field :job_search_apply, :boolean, default: false
    field :job_posting_validity, :integer
    field :additional_tenant_business_charges, :float
    field :tudo_portion_of_consumer_tip, :integer
    field :package_name, :string
    field :additional_branch_office_charges, :float
    field :job_postings, :integer
    field :tasks_events, :boolean, default: false
    field :show_adds, :boolean, default: false
    field :service_appointments, :string
    field :my_net, :boolean, default: false
    belongs_to :country, Countries

    timestamps()
  end

  @doc false
  def changeset(subscription_rule, attrs) do
    subscription_rule
    |> cast(attrs, [
      :country_id,
      :package_id,
      :slug,
      :package_name,
      :package_validity,
      :package_monthly_price,
      :package_annual_price,
      :service_appointments,
      :data_limit,
      :data_unit,
      :data_retention,
      :time_unit,
      :tudo_portion_of_consumer_tip,
      :consolidated_calendar,
      :tasks_events,
      :consumer_family_member,
      :deals,
      :job_search_apply,
      :my_net,
      :consumer_private_messaging,
      :n_ter,
      :business_verification,
      :bus_net,
      :business_private_messaging,
      :branch_offices,
      :additional_branch_office_charges,
      :employees_count,
      :additional_employee_charges,
      :tenant_business_providers,
      :additional_tenant_business_charges,
      :promotions,
      :promotion_validity,
      :additional_promotion_charges,
      :job_postings,
      :job_posting_validity,
      :additional_job_posting_charges,
      :reports_period,
      :payment_with_applied_fee,
      :show_adds,
      :data_privacy,
      :allow_additional_employee,
      :allow_additional_branch_office,
      :allow_additional_tenant_business,
      :allow_additional_promotion,
      :allow_additional_job_posting
    ])
    |> validate_required([
      :package_id,
      :slug,
      :package_name,
      :package_validity,
      :service_appointments,
      :data_limit,
      :data_retention,
      :tudo_portion_of_consumer_tip,
      :consolidated_calendar,
      :tasks_events,
      :consumer_family_member,
      :deals,
      :job_search_apply,
      :my_net,
      :consumer_private_messaging,
      :n_ter,
      :business_verification,
      :bus_net,
      :business_private_messaging,
      :branch_offices,
      :additional_branch_office_charges,
      :employees_count,
      :additional_employee_charges,
      :tenant_business_providers,
      :additional_tenant_business_charges,
      :promotions,
      :promotion_validity,
      :additional_promotion_charges,
      :job_postings,
      :job_posting_validity,
      :additional_job_posting_charges,
      :reports_period,
      :payment_with_applied_fee,
      :show_adds,
      :data_privacy,
      :allow_additional_employee,
      :allow_additional_branch_office,
      :allow_additional_tenant_business,
      :allow_additional_promotion,
      :allow_additional_job_posting
    ])
  end
end
