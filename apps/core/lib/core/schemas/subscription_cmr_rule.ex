defmodule Core.Schemas.SubscriptionCMRRule do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.Countries

  schema "subscription_cmr_rules" do
    field :consumer_family_member, :boolean, default: false
    field :data_privacy, :boolean, default: false
    field :tenant_business_providers, :boolean, default: false
    field :n_ter, :boolean, default: false
    field :data_retention, :integer
    field :payment_with_applied_fee, :boolean, default: false
    field :reports_period, :integer
    field :bus_net, :boolean, default: false
    field :deals, :boolean, default: false
    field :employees, :boolean, default: false
    field :business_private_messaging, :boolean, default: false
    field :branch_offices, :boolean, default: false
    field :consumer_private_messaging, :boolean, default: false
    field :consolidated_calendar, :boolean, default: false
    field :data_limit, :integer
    field :business_verification, :boolean, default: false
    field :promotions, :boolean, default: false
    field :package_id, :string
    field :job_search_apply, :boolean, default: false
    field :tudo_portion_of_consumer_tip, :integer
    field :package_name, :string
    field :package_monthly_price, :float
    field :package_annual_price, :float
    field :package_validity, :string
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
      :package_id,
      :package_name,
      :package_validity,
      :package_monthly_price,
      :package_annual_price,
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
      :tenant_business_providers,
      :promotions,
      :job_postings,
      :reports_period,
      :payment_with_applied_fee,
      :data_privacy,
      :show_adds,
      :country_id
    ])
    |> validate_required([
      :package_id,
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
      :tenant_business_providers,
      :promotions,
      :job_postings,
      :reports_period,
      :payment_with_applied_fee,
      :show_adds,
      :data_privacy
    ])
  end
end
