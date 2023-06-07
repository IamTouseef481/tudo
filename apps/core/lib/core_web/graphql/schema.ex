defmodule CoreWeb.GraphQL.Schema do
  @moduledoc false
  use CoreWeb.GraphQL, :schema
  alias CoreWeb.GraphQL.{Middleware, Resolvers}

  # Import Types
  import_types(CoreWeb.GraphQL.Types)

  query do
    @desc "Get a list of all schedules"
    field :user_schedules, list_of(:user_schedule_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.ScheduleResolver.list_user_schedules/3)
    end

    @desc "Get a list of all promotion statuses"
    field :promotion_statuses, list_of(:promotion_status_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.PromotionResolver.promotion_statuses/3)
    end

    @desc "Get a list of job statuses"
    field :job_statuses, list_of(:job_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.JobResolver.job_statuses/3)
    end

    @desc "Get a list of job categories"
    field :job_categories, list_of(:job_category_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.JobResolver.job_categories/3)
    end

    @desc "Get a list of employee pay rates"
    field :pay_rates, list_of(:pay_rates_type) do
      # Resolversudo apt install postgresql-10-postgis-scripts
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.EmployeeResolver.employee_pay_rates/3)
    end

    @desc "Get a list of employee shift schedules"
    field :shift_schedules, list_of(:shift_schedules_type) do
      # Resolversudo apt install postgresql-10-postgis-scripts
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.EmployeeResolver.employee_shift_schedules/3)
    end

    @desc "Get all Settings"
    field :settings, list_of(:setting_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.SettingResolver.list_settings/3)
    end

    @desc "Get a list of dashboard items"
    field :dashboard_items, list_of(:menu_role_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.MenuResolver.menu_roles/3)
    end

    @desc "Get a list of employees"
    field :employees, list_of(:employee_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.EmployeeResolver.employees/3)
    end

    @desc "Get a list of employees roles"
    field :employee_roles, list_of(:employee_role_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.EmployeeResolver.employee_roles/3)
    end

    @desc "Get a list of employees types"
    field :employee_types, list_of(:employee_type_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.EmployeeResolver.employee_types/3)
    end

    @desc "Get a list of employees status"
    field :employee_statuses, list_of(:employee_status_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.EmployeeResolver.employee_statuses/3)
    end

    @desc "Get a list of employees services"
    field :employee_services, list_of(:employee_service_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.EmployeeResolver.employee_services/3)
    end

    @desc "Get a list of branch service"
    field :branch_services, list_of(:branch_service_type) do
      # Resolver
      resolve(&Resolvers.ServiceResolver.branch_services/3)
    end

    @desc "Get a list of all country service"
    field :country_services, list_of(:country_service_type) do
      # Resolver
      resolve(&Resolvers.ServiceResolver.country_services/3)
    end

    @desc "Get a list of all service"
    field :services, list_of(:service_type) do
      # Resolver
      resolve(&Resolvers.ServiceResolver.services/3)
    end

    @desc "Get a list of all service groups"
    field :service_groups, list_of(:service_group_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.ServiceResolver.service_groups/3)
    end

    @desc "Get a list of all service statuses"
    field :service_statuses, list_of(:service_status_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.ServiceResolver.service_statuses/3)
    end

    @desc "Get a list of all service types"
    field :service_types, list_of(:service_type_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.ServiceResolver.service_types/3)
    end

    @desc "Get a list of all users"
    field :users, list_of(:user_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.UserResolver.users/3)
    end

    @desc "Get a user"
    field :get_user, list_of(:user_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.UserResolver.get_user/3)
    end

    @desc "Get a list of all user statuses"
    field :user_statuses, list_of(:user_status_type) do
      # Resolver
      resolve(&Resolvers.UserResolver.user_statuses/3)
    end

    @desc "Get a list of email templates"
    field :email_templates, list_of(:email_template_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:slug, :string)
      resolve(&Resolvers.EmailTemplateResolver.list_email_templates/3)
    end

    @desc "Get a list of platform terms and conditions"
    field :platform_terms_and_conditions, list_of(:platform_terms_and_conditions_type) do
      # Resolver
      resolve(&Resolvers.LegalResolver.get_all/3)
    end

    @desc "Get a list of platform terms and conditions by country"
    field :platform_terms_and_conditions_by_country_id,
          list_of(:platform_terms_and_conditions_type) do
      # Resolver
      arg(:country_id, non_null(:integer))
      resolve(&Resolvers.LegalResolver.get_by/3)
    end

    @desc "Get a list of licence issuing authorities by country"
    field :licence_issuing_authorities, list_of(:licence_issuing_authorities_type) do
      # Resolver
      arg(:input, non_null(:licence_issueing_authorities_get_type))
      #      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.LegalResolver.get_licence_issuing_authorities_by_country/3)
    end

    @desc "Get a list of business types"
    field :business_types, list_of(:business_type_type) do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.BusinessTypeResolver.list_business_types/3)
    end

    @desc "Get a list of drop downs"
    field :dropdowns, list_of(:dropdown_type) do
      # Resolver
      resolve(&Resolvers.DropdownResolver.list_dropdowns/3)
    end

    @desc "Get a list of dispute categories"
    field :dispute_categories, list_of(:dispute_category_type) do
      # Resolver
      resolve(&Resolvers.PaymentResolver.dispute_categories/3)
    end

    @desc "Get a list of dispute statuses"
    field :dispute_statuses, list_of(:dispute_status_type) do
      # Resolver
      resolve(&Resolvers.PaymentResolver.dispute_statuses/3)
    end

    @desc "Get a list of business"
    field :businesses, list_of(:business_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.BusinessResolver.list_businesses/3)
    end

    @desc "Get a list of branches"
    field :branches, list_of(:branch_list_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, :branch_listing_get_type)
      resolve(&Resolvers.BranchResolver.list_branches_by/3)
    end

    @desc "get Branch"
    field :get_branch, type: :branch_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:branch_delete_type))
      resolve(&Resolvers.BranchResolver.get_branch/3)
    end

    @desc "Get a list of continents"
    field :continents, list_of(:continent_type) do
      # Resolver
      resolve(&Resolvers.RegionResolver.list_continents/3)
    end

    @desc "Get a list of countries"
    field :countries, list_of(:country_type) do
      # Resolver
      resolve(&Resolvers.RegionResolver.list_countries/3)
    end

    @desc "Get a list of languages"
    field :languages, list_of(:language_type) do
      # Resolver
      resolve(&Resolvers.RegionResolver.list_languages/3)
    end

    @desc "get subscription bsp rules"
    field :get_subscription_bsp_rules, list_of(:subscription_bsp_rule_type) do
      # Resolver
      arg(:input, non_null(:subscription_bsp_rule_get_by_country_type))
      resolve(&Resolvers.PaymentResolver.get_subscription_bsp_rules/3)
    end

    @desc "get all dynamic field tags"
    field :dynamic_field_tags, type: list_of(:dynamic_field_tag_type) do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.DynamicResolver.dynamic_field_tags/3)
    end

    @desc "get all dynamic field types"
    field :dynamic_field_types, type: list_of(:dynamic_field_type_type) do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.DynamicResolver.dynamic_field_types/3)
    end

    @desc "translations"
    field :translations, :json do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:translation_input_type))
      resolve(&Resolvers.RegionResolver.translations/3)
    end

    @desc "send in blue email attributes"
    field :send_in_blue_email_attributes, :json do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:translation_input_type))
      resolve(&Resolvers.EmailTemplateResolver.send_in_blue_email_attributes/3)
    end

    @desc "payment methods"
    field :payment_methods, list_of(:payment_method_type) do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:translation_input_type))
      resolve(&Resolvers.PaymentResolver.payment_methods/3)
    end

    @desc "tudo settings"
    field :tudo_settings, list_of(:tudo_setting_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:translation_input_type))
      resolve(&Resolvers.SettingResolver.tudo_settings/3)
    end

    @desc "get admin email notification settings"
    field :get_admin_email_notification_settings,
      type: list_of(:admin_email_notification_settings_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:platform_terms_and_conditions_update_type))
      resolve(&Resolvers.NotificationResolver.get_admin_email_notification_settings/3)
    end

    @desc "list product types"
    field :product_types, list_of(:product_types) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.ProductWarrantyResolver.product_types/2)
    end

    @desc "list product warranty"
    field :product_warranties, list_of(:product_warranty_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.ProductWarrantyResolver.list_product_warranties/2)
    end

    @desc "List bsp template"
    field :bsp_email_templates, list_of(:bsp_email_template_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:email_templates_get_by_type))
      resolve(&Resolvers.BspEmailTemplateResolver.bsp_email_templates/3)
    end

    @desc "List application"
    field :list_application, list_of(:application_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.EmailTemplateResolver.list_application/2)
    end

    @desc "get_country_uom"
    field :get_country_uom_by, :json do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:branch_id, non_null(:integer))
      resolve(&Resolvers.ProductResolver.get_country_uom/3)
    end
  end

  mutation do
    @desc "Read and Insert Raw Businesses From CSV"
    field :create_raw_businesses, list_of(:raw_business_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:raw_business_input_type))
      resolve(&Resolvers.RawBusinessResolver.create_raw_businesses/3)
    end

    @desc "Read and Insert or update From CSV's"
    field :upsert_seeds, list_of(:upsert_seeds_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:upsert_seeds_input_type))
      resolve(&Resolvers.UpsertSeedsResolver.upsert_seeds/3)
    end

    @desc "Get Schedule by user id"
    field :get_user_schedule, list_of(:user_schedule_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_schedule_get_type))
      resolve(&Resolvers.ScheduleResolver.get_user_schedule/3)
    end

    @desc "create services along with_country services"
    field :create_services_along_with_country_services, list_of(:service_type) do
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:create_services_along_with_country_services_type))
      resolve(&Resolvers.ServiceResolver.create_services_along_with_country_services/3)
    end

    @desc "Get Settings by type"
    field :settings_by_type, list_of(:setting_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:setting_get_type))
      resolve(&Resolvers.SettingResolver.settings_by_type/3)
    end

    @desc "create employee details"
    field :create_employee_details, list_of(:cmr_settings_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_details_input_type))
      resolve(&Resolvers.SettingResolver.create_employee_details/3)
    end

    @desc "update employee details"
    field :update_employee_details, :cmr_settings_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cmr_settings_update_type))
      resolve(&Resolvers.SettingResolver.update_cmr_settings/3)
    end

    @desc "get employee details by"
    field :get_employee_details_by, list_of(:cmr_settings_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_details_get_by_type))
      resolve(&Resolvers.SettingResolver.employee_details_get_by/3)
    end

    @desc "create cmr settings"
    field :create_cmr_settings, :cmr_settings_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cmr_settings_input_type))
      resolve(&Resolvers.SettingResolver.create_cmr_settings/3)
    end

    @desc "update cmr settings"
    field :update_cmr_settings, :cmr_settings_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cmr_settings_update_type))
      resolve(&Resolvers.SettingResolver.update_cmr_settings/3)
    end

    @desc "get cmr settings by"
    field :get_cmr_settings_by, list_of(:cmr_settings_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cmr_settings_get_by_type))
      resolve(&Resolvers.SettingResolver.get_cmr_settings_by/3)
    end

    @desc "delete cmr settings"
    field :delete_cmr_settings, :cmr_settings_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cmr_settings_delete_type))
      resolve(&Resolvers.SettingResolver.delete_cmr_settings/3)
    end

    @desc "get cmr preference settings"
    field :get_cmr_preference_settings, list_of(:cmr_settings_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.SettingResolver.get_cmr_preference_settings/3)
    end

    @desc "Create Settings"
    field :create_settings, list_of(:setting_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, :setting_input_type)
      resolve(&Resolvers.SettingResolver.create_settings/3)
    end

    @desc "Update Settings"
    field :update_settings, list_of(:setting_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:setting_update_type))
      resolve(&Resolvers.SettingResolver.update_settings/3)
    end

    @desc "Create BSP Settings"
    field :create_bsp_settings, :bsp_setting_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, :bsp_setting_input_type)
      resolve(&Resolvers.SettingResolver.create_bsp_settings/3)
    end

    @desc "Update BSP Settings"
    field :update_bsp_settings, :bsp_setting_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, :bsp_setting_update_type)
      resolve(&Resolvers.SettingResolver.update_bsp_settings/3)
    end

    @desc "get BSP Settings by"
    field :get_bsp_settings_by, list_of(:bsp_setting_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, :bsp_setting_get_by_type)
      resolve(&Resolvers.SettingResolver.get_bsp_settings_by/3)
    end

    @desc "delete BSP Settings"
    field :delete_bsp_settings, :bsp_setting_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, :bsp_setting_delete_type)
      resolve(&Resolvers.SettingResolver.delete_bsp_settings/3)
    end

    @desc "Update Business Settings"
    field :update_business_settings, :setting_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:business_setting_update_type))
      resolve(&Resolvers.SettingResolver.update_business_settings/3)
    end

    @desc "get Email Settings by user"
    field :get_email_settings_by_user, list_of(:email_setting_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.EmailSettingResolver.get_email_settings_by_user/3)
    end

    @desc "Update Email Settings"
    field :update_email_settings, list_of(:email_setting_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:email_setting_update_type))
      resolve(&Resolvers.EmailSettingResolver.update_email_settings/3)
    end

    @desc "Get Files"
    field :get_files, list_of(:json) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, list_of(:file))
      resolve(&Resolvers.FileResolver.get_files/3)
    end

    @desc "Get zones by country"
    field :get_geo_zones_by_country, list_of(:geo_zone_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:get_zone_input_type))
      resolve(&Resolvers.GeoZoneResolver.get_zones_by_country/3)
    end

    @desc "Get push notifications by user and role"
    field :get_push_notifications_by_user_role, list_of(:push_notification_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, :push_notification_get_by_role_type)
      resolve(&Resolvers.NotificationResolver.get_push_notifications_by_user_role/3)
    end

    @desc "update push notifications"
    field :update_push_notifications, list_of(:push_notification_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, :push_notification_update_type)
      resolve(&Resolvers.NotificationResolver.update_push_notifications/3)
    end

    @desc "create bidding job"
    field :create_bidding_job, type: :bidding_job_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bidding_job_input_type))
      resolve(&Resolvers.BidResolver.create_bidding_job/3)
    end

    @desc "update bidding job"
    field :update_bidding_job, type: :bidding_job_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bidding_job_update_type))
      resolve(&Resolvers.BidResolver.update_bidding_job/3)
    end

    @desc "get bidding jobs by"
    field :get_bidding_jobs_by, type: list_of(:bidding_job_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bidding_job_get_by_type))
      resolve(&Resolvers.BidResolver.get_bidding_jobs_by/3)
    end

    @desc "delete bidding job"
    field :delete_bidding_job, type: :bidding_job_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bidding_job_delete_type))
      resolve(&Resolvers.BidResolver.delete_bidding_job/3)
    end

    @desc "create bid proposal"
    field :create_bid_proposal, type: :bid_proposal_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bid_proposal_input_type))
      resolve(&Resolvers.BidResolver.create_bid_proposal/3)
    end

    @desc "update bid proposal"
    field :update_bid_proposal, type: :bid_proposal_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bid_proposal_update_type))
      resolve(&Resolvers.BidResolver.update_bid_proposal/3)
    end

    @desc "get bid_proposals by "
    field :get_bid_proposals_by, type: list_of(:bid_proposal_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bid_proposal_get_type))
      resolve(&Resolvers.BidResolver.get_bid_proposals_by/3)
    end

    @desc "delete bid proposals"
    field :delete_bid_proposal, type: :bid_proposal_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bid_proposal_delete_type))
      resolve(&Resolvers.BidResolver.delete_bid_proposal/3)
    end

    @desc "Post job On CMR Behalf"
    field :post_job_on_cmr_behalf, type: :job_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_post_onbehalf_input_type))
      resolve(&Resolvers.JobResolver.post_job_on_behalf/3)
    end

    @desc "Post job"
    field :post_job, type: list_of(:job_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_input_type))
      resolve(&Resolvers.JobResolver.post_job/3)
    end

    @desc "create job note"
    field :create_job_note, type: :job_note_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_note_input_type))
      resolve(&Resolvers.JobResolver.create_job_note/3)
    end

    @desc "show job note"
    field :show_job_note, type: list_of(:job_note_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:show_job_note_input_type))
      resolve(&Resolvers.JobResolver.show_job_note/3)
    end

    @desc "Update job"
    field :update_job, type: :job_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_update_type))
      resolve(&Resolvers.JobResolver.update_job/3)
    end

    @desc "CMR requests revise job estimate"
    field :revise_job_estimate, type: :job_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_estimate_revise_type))
      resolve(&Resolvers.JobResolver.revise_job_estimate/3)
    end

    @desc "BSP makes job estimate"
    field :make_job_estimate, type: :job_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_estimate_make_type))
      resolve(&Resolvers.JobResolver.make_job_estimate/3)
    end

    @desc "BSP update job estimate"
    field :update_job_estimate, type: :job_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_estimate_update_type))
      resolve(&Resolvers.JobResolver.update_job_estimate/3)
    end

    @desc "Get a list of leads for BSP"
    field :get_leads_for_bsp, :lead_for_bsp_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:lead_get_type))
      resolve(&Resolvers.LeadResolver.get_leads_for_bsp/3)
    end

    @desc "Get a list of prospects for BSP"
    field :get_prospects_for_bsp, :lead_for_bsp_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:prospect_get_type))
      resolve(&Resolvers.LeadResolver.get_prospects_for_bsp/3)
    end

    @desc " Get a list of CMR jobs"
    field :get_jobs_for_cmr, list_of(:job_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_get_cmr_type))
      resolve(&Resolvers.JobResolver.get_jobs_for_cmr/3)
    end

    @desc "Get a list of BSP jobs"
    field :get_jobs_for_bsp, list_of(:job_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_get_bsp_type))
      resolve(&Resolvers.JobResolver.get_jobs_for_bsp/3)
    end

    @desc "Get user or employee ratings and reviews"
    field :get_ratings_by, :rating_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:rating_get_type))
      resolve(&Resolvers.JobResolver.get_ratings_by/3)
    end

    @desc "Get a list of employee jobs"
    field :get_employee_jobs, list_of(:job_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_by_branch_id_type))
      resolve(&Resolvers.JobResolver.get_employee_jobs/3)
    end

    @desc "Get a list of job history"
    field :get_job_histoy, list_of(:job_history_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_history_get_type))
      resolve(&Resolvers.JobResolver.get_job_history/3)
    end

    @desc "Get availability"
    field :get_availability, type: :get_availability_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:availability_input_type))
      resolve(&Resolvers.SearchBSPResolver.get_availability/3)
    end

    @desc "Get Branch availability"
    field :get_branch_availability, type: :get_branch_availability_type do
      # Resolver
      arg(:input, non_null(:branch_availability_input_type))
      resolve(&Resolvers.SearchBSPResolver.get_branch_availability/3)
    end

    @desc "Search BSP"
    field :search_bsp, list_of(:search_bsp_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:search_bsp_get_type))
      resolve(&Resolvers.SearchBSPResolver.search_bsp/3)
    end

    @desc "BSP general search"
    field :bsp_general_search, :bsp_general_search_type do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bsp_general_search_get_type))
      resolve(&Resolvers.SearchBSPResolver.bsp_general_search/3)
    end

    @desc "Get a list of calendar by"
    field :calendar_by_user_id, type: :calendar_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:calendar_get_type))
      resolve(&Resolvers.CalendarResolver.get_calendar_by/3)
    end

    @desc "create a pay rate"
    field :create_pay_rate, type: :pay_rate_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:pay_rate_input_type))
      resolve(&Resolvers.EmployeeResolver.create_pay_rate/3)
    end

    @desc "get a pay rate"
    field :get_pay_rate, type: :pay_rate_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:pay_rate_get_type))
      resolve(&Resolvers.EmployeeResolver.get_pay_rate/3)
    end

    @desc "update a pay rate"
    field :update_pay_rate, type: :pay_rate_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:pay_rate_update_type))
      resolve(&Resolvers.EmployeeResolver.update_pay_rate/3)
    end

    @desc "delete a pay rate"
    field :delete_pay_rate, type: :pay_rate_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:pay_rate_get_type))
      resolve(&Resolvers.EmployeeResolver.delete_pay_rate/3)
    end

    @desc "create an employee role"
    field :create_employee_role, type: :employee_role_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_role_input_type))
      resolve(&Resolvers.EmployeeResolver.create_employee_role/3)
    end

    @desc "get an employee role"
    field :get_employee_role, type: :employee_role_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_role_get_type))
      resolve(&Resolvers.EmployeeResolver.get_employee_role/3)
    end

    @desc "update an employee role"
    field :update_employee_role, type: :employee_role_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_role_update_type))
      resolve(&Resolvers.EmployeeResolver.update_employee_role/3)
    end

    @desc "delete an employee role"
    field :delete_employee_role, type: :employee_role_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_role_get_type))
      resolve(&Resolvers.EmployeeResolver.delete_employee_role/3)
    end

    @desc "create an employee status"
    field :create_employee_status, type: :employee_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_status_input_type))
      resolve(&Resolvers.EmployeeResolver.create_employee_status/3)
    end

    @desc "get an employee status"
    field :get_employee_status, type: :employee_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_status_get_type))
      resolve(&Resolvers.EmployeeResolver.get_employee_status/3)
    end

    @desc "update an employee status"
    field :update_employee_status, type: :employee_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_status_update_type))
      resolve(&Resolvers.EmployeeResolver.update_employee_status/3)
    end

    @desc "delete an employee status"
    field :delete_employee_status, type: :employee_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_status_get_type))
      resolve(&Resolvers.EmployeeResolver.delete_employee_status/3)
    end

    @desc "create an employee type"
    field :create_employee_type, type: :employee_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_type_input_type))
      resolve(&Resolvers.EmployeeResolver.create_employee_type/3)
    end

    @desc "get an employee type"
    field :get_employee_type, type: :employee_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_type_get_type))
      resolve(&Resolvers.EmployeeResolver.get_employee_type/3)
    end

    @desc "update an employee type"
    field :update_employee_type, type: :employee_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_type_update_type))
      resolve(&Resolvers.EmployeeResolver.update_employee_type/3)
    end

    @desc "delete an employee type"
    field :delete_employee_type, type: :employee_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_type_get_type))
      resolve(&Resolvers.EmployeeResolver.delete_employee_type/3)
    end

    @desc "create employee setting"
    field :create_employee_setting, type: :employee_setting_type do
      # Resolver
      arg(:input, non_null(:employee_setting_input_type))
      resolve(&Resolvers.EmployeeResolver.create_employee_setting/3)
    end

    @desc "get employee setting"
    field :get_employee_setting, type: list_of(:employee_setting_type) do
      # Resolver
      arg(:input, non_null(:employee_setting_get_type))
      resolve(&Resolvers.EmployeeResolver.get_employee_setting/3)
    end

    @desc "update employee setting"
    field :update_employee_setting, type: :employee_setting_type do
      # Resolver
      arg(:input, non_null(:employee_setting_update_type))
      resolve(&Resolvers.EmployeeResolver.update_employee_setting/3)
    end

    @desc "delete employee setting"
    field :delete_employee_setting, type: :employee_setting_type do
      # Resolver
      arg(:input, non_null(:employee_setting_get_type))
      resolve(&Resolvers.EmployeeResolver.delete_employee_setting/3)
    end

    #
    #    @desc "create manage_employee"
    #    field :create_manage_employee, type: :manage_employee_type do
    #      # Resolver
    #      arg(:input, non_null(:manage_employee_input_type))
    #      resolve(&Resolvers.EmployeeResolver.create_manage_employee/3)
    #    end
    #    @desc "get manage_employee"
    #    field :get_manage_employee, type: :manage_employee_type do
    #      # Resolver
    #      arg(:input, non_null(:manage_employee_get_type))
    #      resolve(&Resolvers.EmployeeResolver.get_manage_employee/3)
    #    end
    #    @desc "update manage_employee"
    #    field :update_manage_employee, type: :manage_employee_type do
    #      # Resolver
    #      arg(:input, non_null(:manage_employee_update_type))
    #      resolve(&Resolvers.EmployeeResolver.update_manage_employee/3)
    #    end
    #    @desc "delete manage_employee"
    #    field :delete_manage_employee, type: :manage_employee_type do
    #      # Resolver
    #      arg(:input, non_null(:manage_employee_delete_type))
    #      resolve(&Resolvers.EmployeeResolver.delete_manage_employee/3)
    #    end

    @desc "Get a list of employees by branch id"
    field :employees_by_branch_id, list_of(:employee_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_get_type))
      resolve(&Resolvers.EmployeeResolver.get_employees_by_branch_id/3)
    end

    @desc "Get a list of employees by user id"
    field :employees_by_user_id, list_of(:employee_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_by_user_id_type))
      resolve(&Resolvers.EmployeeResolver.get_employees_by_user_id/3)
    end

    @desc "Invite user"
    field :invite_user, type: :user_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:invite_user_input_type))
      resolve(&Resolvers.UserResolver.invite_user/3)
    end

    @desc "Invite employee"
    field :invite_employee, type: :employee_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:invite_employee_input_type))
      resolve(&Resolvers.EmployeeResolver.invite_employee/3)
    end

    @desc "Update employee"
    field :update_employee, type: :employee_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_update_type))
      resolve(&Resolvers.EmployeeResolver.update_employee/3)
    end

    @desc "Update employee location"
    field :update_employee_location, type: :employee_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_location_update_type))
      resolve(&Resolvers.EmployeeResolver.update_location_employee/3)
    end

    @desc "Delete employee"
    field :delete_employee, type: :employee_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_delete_type))
      resolve(&Resolvers.EmployeeResolver.delete_employee/3)
    end

    @desc "Create employee service"
    field :create_employee_service, type: :employee_service_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_service_input_type))
      resolve(&Resolvers.EmployeeResolver.create_employee_service/3)
    end

    @desc "Update employee service"
    field :update_employee_service, type: :employee_service_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_service_update_type))
      resolve(&Resolvers.EmployeeResolver.update_employee_service/3)
    end

    @desc "Delete employee service"
    field :delete_employee_service, type: :employee_service_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:employee_service_delete_type))
      resolve(&Resolvers.EmployeeResolver.delete_employee_service/3)
    end

    @desc "create employee shift schedule"
    field :create_shift_schedule, type: :shift_schedules_type do
      # Resolver
      arg(:input, non_null(:shift_schedule_input_type))
      resolve(&Resolvers.EmployeeResolver.create_shift_schedule/3)
    end

    @desc "get employee shift schedule"
    field :get_shift_schedule, type: :shift_schedules_type do
      # Resolver
      arg(:input, non_null(:shift_schedule_get_type))
      resolve(&Resolvers.EmployeeResolver.get_shift_schedule/3)
    end

    @desc "update employee shift schedule"
    field :update_shift_schedule, type: :shift_schedules_type do
      # Resolver
      arg(:input, non_null(:shift_schedule_update_type))
      resolve(&Resolvers.EmployeeResolver.update_shift_schedule/3)
    end

    @desc "delete employee shift schedule"
    field :delete_shift_schedule, type: :shift_schedules_type do
      # Resolver
      arg(:input, non_null(:shift_schedule_get_type))
      resolve(&Resolvers.EmployeeResolver.delete_shift_schedule/3)
    end

    @desc "get bsp meta"
    field :get_bsp_meta, type: list_of(:meta_bsp_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bsp_meta_get_type))
      resolve(&Resolvers.MetaResolver.get_bsp_meta/3)
    end

    @desc "delete bsp meta"
    field :delete_bsp_meta, type: :meta_bsp_type do
      # Resolver
      arg(:input, non_null(:meta_delete_type))
      resolve(&Resolvers.MetaResolver.delete_bsp_meta/3)
    end

    @desc "get cmr meta"
    field :get_cmr_meta, type: list_of(:meta_cmr_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cmr_meta_get_type))
      resolve(&Resolvers.MetaResolver.get_cmr_meta/3)
    end

    @desc "delete cmr meta"
    field :delete_cmr_meta, type: :meta_cmr_type do
      # Resolver
      arg(:input, non_null(:meta_delete_type))
      resolve(&Resolvers.MetaResolver.delete_cmr_meta/3)
    end

    @desc "create a branch service"
    field :create_branch_service, type: :branch_service_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:branch_service_input_type))
      resolve(&Resolvers.ServiceResolver.create_branch_service/3)
    end

    @desc "update a branch service"
    field :update_branch_service, type: :branch_service_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:branch_service_update_type))
      resolve(&Resolvers.ServiceResolver.update_branch_service/3)
    end

    @desc "get branch services by branch"
    field :get_branch_services_by_branch, type: list_of(:branch_service_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:branch_service_get_type))
      resolve(&Resolvers.ServiceResolver.get_branch_services_by_branch/3)
    end

    @desc "update all branch services of single type"
    field :update_multiple_branch_services, type: list_of(:branch_service_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:branch_services_update_type))
      resolve(&Resolvers.ServiceResolver.update_multiple_branch_services/3)
    end

    @desc "delete a branch service"
    field :delete_branch_service, type: :branch_service_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:branch_service_delete_type))
      resolve(&Resolvers.ServiceResolver.delete_branch_service/3)
    end

    @desc "create a promotion status"
    field :create_promotion_status, type: :promotion_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_status_input_type))
      resolve(&Resolvers.PromotionResolver.create_promotion_status/3)
    end

    @desc "get a promotion status"
    field :get_promotion_status, type: :promotion_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_status_get_type))
      resolve(&Resolvers.PromotionResolver.get_promotion_status/3)
    end

    @desc "update a promotion status"
    field :update_promotion_status, type: :promotion_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_status_update_type))
      resolve(&Resolvers.PromotionResolver.update_promotion_status/3)
    end

    @desc "delete a promotion status"
    field :delete_promotion_status, type: :promotion_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_status_get_type))
      resolve(&Resolvers.PromotionResolver.delete_promotion_status/3)
    end

    @desc "Get deals by"
    field :get_deals_by, list_of(:promotion_type) do
      # Resolver
      arg(:input, non_null(:deal_get_type))
      resolve(&Resolvers.PromotionResolver.get_deals_by/3)
    end

    @desc "Get promotion by service id"
    field :get_promotion_by_service, list_of(:promotion_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_get_type))
      resolve(&Resolvers.PromotionResolver.get_promotion_by_service/3)
    end

    @desc "Get promotion by branch"
    field :get_promotion_by_branch, list_of(:promotion_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:get_promotions_by_branch_type))
      resolve(&Resolvers.PromotionResolver.get_promotions_by_branch/3)
    end

    #
    #    @desc "Get promotion by business"
    #    field :get_promotions_by_business, list_of(:promotion_type) do
    #      # Resolver
    #      middleware(Middleware.Authorize, :any)
    #      arg(:input, non_null(:get_promotions_by_business_type))
    #      resolve(&Resolvers.PromotionResolver.get_promotions_by_business/3)
    #    end
    @desc "Create promotion"
    field :create_promotion, :promotion_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_input_type))
      resolve(&Resolvers.PromotionResolver.create_promotion/3)
    end

    @desc "Update promotion"
    field :update_promotion, :promotion_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_update_type))
      resolve(&Resolvers.PromotionResolver.update_promotion/3)
    end

    #    @desc "Get invoice by id"
    #    field :get_invoice, list_of(:invoice_type) do
    #      # Resolver
    #      middleware(Middleware.Authorize, :any)
    #      arg(:input, non_null(:invoice_get_type))
    #      resolve(&Resolvers.InvoiceResolver.get_invoice/3)
    #    end
    @desc "get invoice by job id"
    field :get_invoice_by_job, list_of(:invoice_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:invoice_get_type))
      resolve(&Resolvers.InvoiceResolver.get_invoice_by_job/3)
    end

    @desc "Update invoice"
    field :update_invoice, :invoice_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:invoice_update_type))
      resolve(&Resolvers.InvoiceResolver.update_invoice/3)
    end

    @desc "generate invoice"
    field :generate_invoice, :invoice_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:invoice_generate_type))
      resolve(&Resolvers.InvoiceResolver.generate_invoice/3)
    end

    @desc "adjust invoice"
    field :adjust_invoice, list_of(:invoice_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:invoice_adjust_type))
      resolve(&Resolvers.InvoiceResolver.adjust_invoice/3)
    end

    @desc "get taxes by business"
    field :get_taxes_by_business, list_of(:tax_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:tax_get_type))
      resolve(&Resolvers.TaxResolver.get_taxes_by_business/3)
    end

    @desc "create tax"
    field :create_tax, :tax_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:tax_input_type))
      resolve(&Resolvers.TaxResolver.create_tax/3)
    end

    @desc "Update tax"
    field :update_tax, :tax_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:tax_update_type))
      resolve(&Resolvers.TaxResolver.update_tax/3)
    end

    @desc "delete tax"
    field :delete_tax, :tax_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:tax_delete_type))
      resolve(&Resolvers.TaxResolver.delete_tax/3)
    end

    @desc "Update branch"
    field :update_branch, type: :branch_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:branch_update_type))
      resolve(&Resolvers.BranchResolver.update_branch/3)
    end

    @desc "Make branch active"
    field :make_branch_active, type: :branch_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:branch_activate_type))
      resolve(&Resolvers.BranchResolver.make_branch_active/3)
    end

    @desc "Create Branch"
    field :create_branch, type: :branch_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:branch_input_type))
      resolve(&Resolvers.BranchResolver.create_branch/3)
    end

    @desc "Delete Branch"
    field :delete_branch, type: :branch_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:branch_delete_type))
      resolve(&Resolvers.BranchResolver.delete_branch/3)
    end

    @desc "Get a list of services for specific country"
    field :services_by_country, type: :json do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:country_service_group_type))
      resolve(&Resolvers.ServiceResolver.get_services_by_country_id/3)
    end

    @desc "create a country service"
    field :create_country_service, type: :country_service_type do
      # Resolver
      arg(:input, non_null(:country_service_input_type))
      resolve(&Resolvers.ServiceResolver.create_country_service/3)
    end

    @desc "update a country service"
    field :update_country_service, type: :country_service_type do
      # Resolver
      arg(:input, non_null(:country_service_update_type))
      resolve(&Resolvers.ServiceResolver.update_country_service/3)
    end

    @desc "delete a country service"
    field :delete_country_service, type: :country_service_type do
      # Resolver
      arg(:input, non_null(:country_service_delete_type))
      resolve(&Resolvers.ServiceResolver.delete_country_service/3)
    end

    @desc "Get service settings by country service id"
    field :service_settings_by, list_of(:service_setting_type) do
      # Resolver
      arg(:input, non_null(:get_service_setting_input_type))
      resolve(&Resolvers.ServiceResolver.service_settings_by/3)
    end

    @desc "create a service settings"
    field :create_service_setting, type: :service_setting_type do
      # Resolver
      arg(:input, non_null(:service_setting_input_type))
      resolve(&Resolvers.ServiceResolver.create_service_setting/3)
    end

    @desc "update a service setting"
    field :update_service_setting, type: :service_setting_type do
      # Resolver
      arg(:input, non_null(:service_setting_update_type))
      resolve(&Resolvers.ServiceResolver.update_service_setting/3)
    end

    @desc "delete a service setting"
    field :delete_service_setting, type: :service_setting_type do
      # Resolver
      arg(:input, non_null(:service_setting_delete_type))
      resolve(&Resolvers.ServiceResolver.delete_service_setting/3)
    end

    @desc "create a service group"
    field :create_service_group, type: :service_group_type do
      # Resolver
      arg(:input, non_null(:service_group_input_type))
      resolve(&Resolvers.ServiceResolver.create_service_group/3)
    end

    @desc "update a service group"
    field :update_service_group, type: :service_group_type do
      # Resolver
      arg(:input, non_null(:service_group_update_type))
      resolve(&Resolvers.ServiceResolver.update_service_group/3)
    end

    @desc "delete a service group"
    field :delete_service_group, type: :service_group_type do
      # Resolver
      arg(:input, non_null(:service_group_delete_type))
      resolve(&Resolvers.ServiceResolver.delete_service_group/3)
    end

    @desc "get a service group"
    field :get_service_group, type: :service_group_type do
      # Resolver
      arg(:input, non_null(:service_group_delete_type))
      resolve(&Resolvers.ServiceResolver.get_service_group/3)
    end

    @desc "create a service status"
    field :create_service_status, type: :service_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:service_status_input_type))
      resolve(&Resolvers.ServiceResolver.create_service_status/3)
    end

    @desc "get a service status"
    field :get_service_status, type: :service_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:service_status_get_type))
      resolve(&Resolvers.ServiceResolver.get_service_status/3)
    end

    @desc "update a service status"
    field :update_service_status, type: :service_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:service_status_update_type))
      resolve(&Resolvers.ServiceResolver.update_service_status/3)
    end

    @desc "delete a service status"
    field :delete_service_status, type: :service_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:service_status_get_type))
      resolve(&Resolvers.ServiceResolver.delete_service_status/3)
    end

    @desc "create a service type"
    field :create_service_type, type: :service_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:service_type_input_type))
      resolve(&Resolvers.ServiceResolver.create_service_type/3)
    end

    @desc "get a service type"
    field :get_service_type, type: :service_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:service_type_get_type))
      resolve(&Resolvers.ServiceResolver.get_service_type/3)
    end

    @desc "update a service type"
    field :update_service_type, type: :service_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:service_type_update_type))
      resolve(&Resolvers.ServiceResolver.update_service_type/3)
    end

    @desc "delete a service type"
    field :delete_service_type, type: :service_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:service_type_get_type))
      resolve(&Resolvers.ServiceResolver.delete_service_type/3)
    end

    @desc "create a service"
    field :create_service, type: :service_type do
      # Resolver
      arg(:input, non_null(:service_input_type))
      resolve(&Resolvers.ServiceResolver.create_service/3)
    end

    @desc "update a service"
    field :update_service, type: :service_type do
      # Resolver
      arg(:input, non_null(:service_update_type))
      resolve(&Resolvers.ServiceResolver.update_service/3)
    end

    @desc "delete a service"
    field :delete_service, type: :service_type do
      # Resolver
      arg(:input, non_null(:service_delete_type))
      resolve(&Resolvers.ServiceResolver.delete_service/3)
    end

    @desc "get holidays"
    field :get_holidays, list_of(:holiday_type) do
      # Resolver
      arg(:input, non_null(:holiday_get_type))
      resolve(&Resolvers.OffDayResolver.holidays_by/3)
    end

    @desc "create holidays"
    field :create_holidays, type: :holiday_type do
      # Resolver
      arg(:input, non_null(:holiday_input_type))
      resolve(&Resolvers.OffDayResolver.create_holidays/3)
    end

    @desc "update a holidays"
    field :update_holidays, type: :holiday_type do
      # Resolver
      arg(:input, non_null(:holiday_update_type))
      resolve(&Resolvers.OffDayResolver.update_holidays/3)
    end

    @desc "delete a holidays"
    field :delete_holidays, type: :holiday_type do
      # Resolver
      arg(:input, non_null(:holiday_delete_type))
      resolve(&Resolvers.OffDayResolver.delete_holidays/3)
    end

    @desc "create a user status"
    field :create_user_status, type: :user_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_status_input_type))
      resolve(&Resolvers.UserResolver.create_user_status/3)
    end

    @desc "get a user status"
    field :get_user_status, type: :user_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_status_get_type))
      resolve(&Resolvers.UserResolver.get_user_status/3)
    end

    @desc "update a user status"
    field :update_user_status, type: :user_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_status_update_type))
      resolve(&Resolvers.UserResolver.update_user_status/3)
    end

    @desc "delete a user status"
    field :delete_user_status, type: :user_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_status_get_type))
      resolve(&Resolvers.UserResolver.delete_user_status/3)
    end

    @desc "create user schedule"
    field :create_user_schedule, type: :user_schedule_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_schedule_input_type))
      resolve(&Resolvers.ScheduleResolver.create_user_schedule/3)
    end

    #    @desc "get user schedule"
    #    field :get_user_schedules, type: :user_schedule_type do
    #      # Resolver
    #      middleware(Middleware.Authorize, :any)
    #      arg(:input, non_null(:user_schedule_delete_type))
    #      resolve(&Resolvers.ScheduleResolver.get_user_schedule/3)
    #    end
    @desc "update user schedule"
    field :update_user_schedule, type: :user_schedule_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_schedule_update_type))
      resolve(&Resolvers.ScheduleResolver.update_user_schedule/3)
    end

    @desc "delete user schedule"
    field :delete_user_schedule, type: :user_schedule_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_schedule_delete_type))
      resolve(&Resolvers.ScheduleResolver.delete_user_schedule/3)
    end

    @desc "create a user"
    field :create_user, type: :user_type do
      # Resolver
      arg(:input, non_null(:user_input_type))
      resolve(&Resolvers.UserResolver.create_user/3)
    end

    @desc "update user install"
    field :update_user_install, type: :user_installs_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_install_fcm_token_update_type))
      resolve(&Resolvers.UserResolver.update_user_install/3)
    end

    @desc "update a user"
    field :update_user, type: :user_type do
      # Resolverusers
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_update_type))
      resolve(&Resolvers.UserResolver.update_user/3)
    end

    @desc "delete a user"
    field :delete_user, type: :delete_user_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:delete_user_input_type))
      resolve(&Resolvers.UserResolver.delete_user/3)
    end

    @desc "get user addresses"
    field :get_user_addresses, list_of(:user_address_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_address_get_type))
      resolve(&Resolvers.UserResolver.get_user_addresses/3)
    end

    @desc "get user by"
    field :get_user_by, :get_user_by_type do
      # Resolver
      arg(:input, non_null(:get_user_by_input_type))
      resolve(&Resolvers.UserResolver.get_user_by/3)
    end

    @desc "create user address"
    field :create_user_address, list_of(:user_address_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_address_input_type))
      resolve(&Resolvers.UserResolver.create_user_address/3)
    end

    @desc "update user address"
    field :update_user_address, list_of(:user_address_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_address_update_type))
      resolve(&Resolvers.UserResolver.update_user_address/3)
    end

    @desc "delete user address"
    field :delete_user_address, type: :user_address_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_address_delete_type))
      resolve(&Resolvers.UserResolver.delete_user_address/3)
    end

    @desc "register confirmation"
    field :register_confirmation, type: :user_type do
      # Resolver
      arg(:input, non_null(:register_confirmation_input_type))
      resolve(&Resolvers.UserResolver.register_confirmation/3)
    end

    @desc "send confirmation token"
    field :send_token, type: :user_type do
      # Resolver
      arg(:input, non_null(:session_send_input_type))
      resolve(&Resolvers.UserResolver.send_token/3)
    end

    @desc "forget password"
    field :forget_password, type: :user_type do
      # Resolver
      arg(:input, non_null(:session_forget_input_type))
      resolve(&Resolvers.UserResolver.forget_password/3)
    end

    @desc "create platform terms and conditions"
    field :create_platform_term_and_condition, type: :platform_terms_and_conditions_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:platform_terms_and_conditions_input_type))
      resolve(&Resolvers.LegalResolver.create_platform_term_and_condition/3)
    end

    @desc "update platform terms and conditions"
    field :update_platform_term_and_condition, type: :platform_terms_and_conditions_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:platform_terms_and_conditions_update_type))
      resolve(&Resolvers.LegalResolver.update_platform_term_and_condition/3)
    end

    @desc "update admin email notification settings"
    field :update_admin_email_notification_settings, type: :admin_email_notification_settings_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:admin_email_notification_settings_update_type))
      resolve(&Resolvers.NotificationResolver.update_admin_email_notification_settings/3)
    end

    @desc "accept platform terms and condition"
    field :accept_platform_term_and_condition, type: :meta_bsp_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:platform_terms_and_conditions_accept_type))
      resolve(&Resolvers.LegalResolver.accept_platform_term_and_condition/3)
    end

    @desc "create email templates"
    field :create_email_templates, type: list_of(:email_template_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:email_template_input_type))
      resolve(&Resolvers.EmailTemplateResolver.create_email_template/3)
    end

    @desc "create a business type"
    field :create_business_type, type: :business_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:business_type_input_type))
      resolve(&Resolvers.BusinessTypeResolver.create_business_type/3)
    end

    @desc "update a business type"
    field :update_business_type, type: :business_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:business_type_update_type))
      resolve(&Resolvers.BusinessTypeResolver.update_business_type/3)
    end

    @desc "get a business type"
    field :get_business_type, type: :business_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:business_type_get_type))
      resolve(&Resolvers.BusinessTypeResolver.get_business_type/3)
    end

    @desc "delete a business type"
    field :delete_business_type, type: :business_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:business_type_get_type))
      resolve(&Resolvers.BusinessTypeResolver.delete_business_type/3)
    end

    #    @desc "create business terms and conditions"
    #    field :create_business_type, type: :business_type_type do
    #      # Resolver
    #      arg(:input, non_null(:business_type_input_type))
    #      resolve(&Resolvers.BusinessTypeResolver.create_business_type/3)
    #    end
    #    @desc "update business terms and conditions"
    #    field :update_business_type, type: :business_type_type do
    #      # Resolver
    #      arg(:input, non_null(:business_type_update_type))
    #      resolve(&Resolvers.BusinessTypeResolver.update_business_type/3)
    #    end
    #    @desc "delete business terms and conditions"
    #    field :delete_business_type, type: :business_type_type do
    #      # Resolver
    #      arg(:input, non_null(:business_type_get_type))
    #      resolve(&Resolvers.BusinessTypeResolver.delete_business_type/3)
    #    end

    @desc "create a straight business with minimal information"
    field :create_straight_business, type: :business_type do
      # Resolver
      arg(:input, non_null(:business_straight_input_type))
      #      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.BusinessResolver.create_straight_business/3)
    end

    #    @desc "update a straight business"
    #    field :update_straight_business, type: :business_type do
    #      # Resolver
    #      arg(:input, non_null(:business_straight_update_type))
    ##      middleware(Middleware.Authorize, :any)
    #      resolve(&Resolvers.BusinessResolver.update_straight_business/3)
    #    end

    @desc "create a business"
    field :create_business, type: :business_type do
      # Resolver
      arg(:input, non_null(:business_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.BusinessResolver.create_business/3)
    end

    @desc "update a business"
    field :update_business, type: :business_type do
      # Resolver
      arg(:input, non_null(:business_update_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.BusinessResolver.update_business/3)
    end

    @desc "Make business active"
    field :make_business_active, type: :business_type do
      # Resolver
      arg(:input, non_null(:business_activate_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.BusinessResolver.make_business_active/3)
    end

    @desc "get a business by user id"
    field :get_business_by_user_id, list_of(:business_type) do
      # Resolver
      arg(:input, non_null(:business_delete_type))
      resolve(&Resolvers.BusinessResolver.get_business/3)
    end

    @desc "get drop downs by type"
    field :get_dropdowns_by_type, list_of(:dropdown_type) do
      # Resolver
      arg(:input, non_null(:dropdown_select_type))
      resolve(&Resolvers.DropdownResolver.get_dropdowns/3)
    end

    @desc "delete a business"
    field :delete_business, type: :business_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:business_delete_type))
      resolve(&Resolvers.BusinessResolver.delete_business/3)
    end

    @desc "cmr straight signup with minimal information"
    field :cmr_staight_signup, type: :user_type do
      # Resolver
      arg(:input, non_null(:user_input_type))
      resolve(&Resolvers.UserResolver.create_straight_user/3)
    end

    @desc "login a user"
    field :login_user, type: :session_type do
      # Resolver
      arg(:input, non_null(:session_input_type))
      resolve(&Resolvers.UserResolver.login_user/3)
    end

    @desc "logout a user"
    field :logout_user, :logout_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:session_logout_type))
      resolve(&Resolvers.UserResolver.logout/3)
    end

    @desc "create a dynamic field tag"
    field :create_dynamic_field_tag, type: :dynamic_field_tag_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_field_tag_input_type))
      resolve(&Resolvers.DynamicResolver.create_dynamic_field_tag/3)
    end

    @desc "get a dynamic field tag"
    field :get_dynamic_field_tag, type: :dynamic_field_tag_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_field_tag_get_type))
      resolve(&Resolvers.DynamicResolver.get_dynamic_field_tag/3)
    end

    @desc "update a dynamic field tag"
    field :update_dynamic_field_tag, type: :dynamic_field_tag_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_field_tag_update_type))
      resolve(&Resolvers.DynamicResolver.update_dynamic_field_tag/3)
    end

    @desc "delete a dynamic field tag"
    field :delete_dynamic_field_tag, type: :dynamic_field_tag_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_field_tag_get_type))
      resolve(&Resolvers.DynamicResolver.delete_dynamic_field_tag/3)
    end

    @desc "create a dynamic field type"
    field :create_dynamic_field_type, type: :dynamic_field_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_field_type_input_type))
      resolve(&Resolvers.DynamicResolver.create_dynamic_field_type/3)
    end

    @desc "get a dynamic field type"
    field :get_dynamic_field_type, type: :dynamic_field_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_field_type_get_type))
      resolve(&Resolvers.DynamicResolver.get_dynamic_field_type/3)
    end

    @desc "update a dynamic field type"
    field :update_dynamic_field_type, type: :dynamic_field_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_field_type_update_type))
      resolve(&Resolvers.DynamicResolver.update_dynamic_field_type/3)
    end

    @desc "delete a dynamic field type"
    field :delete_dynamic_field_type, type: :dynamic_field_type_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_field_value_get_type))
      resolve(&Resolvers.DynamicResolver.delete_dynamic_field_type/3)
    end

    @desc "create a dynamic field value"
    field :create_dynamic_field_value, type: :dynamic_field_value_type do
      # Resolver
      arg(:input, non_null(:dynamic_field_value_input_type))
      resolve(&Resolvers.DynamicResolver.create_dynamic_field_value/3)
    end

    @desc "get a dynamic field value"
    field :get_dynamic_field_value, type: :dynamic_field_value_type do
      # Resolver
      arg(:input, non_null(:dynamic_field_value_get_type))
      resolve(&Resolvers.DynamicResolver.get_dynamic_field_value/3)
    end

    @desc "update a dynamic field value"
    field :update_dynamic_field_value, type: :dynamic_field_value_type do
      # Resolver
      arg(:input, non_null(:dynamic_field_value_update_type))
      resolve(&Resolvers.DynamicResolver.update_dynamic_field_value/3)
    end

    @desc "delete a dynamic field value"
    field :delete_dynamic_field_value, type: :dynamic_field_value_type do
      # Resolver
      arg(:input, non_null(:dynamic_field_value_get_type))
      resolve(&Resolvers.DynamicResolver.delete_dynamic_field_value/3)
    end

    @desc "Get dynamic screens by"
    field :get_dynamic_screens_by, list_of(:dynamic_screen_type) do
      # Resolver
      arg(:input, non_null(:dynamic_screen_get_type))
      resolve(&Resolvers.DynamicResolver.get_dynamic_screens_by/3)
    end

    @desc "create dynamic screen"
    field :create_dynamic_screen, list_of(:dynamic_screen_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_screen_input_type))
      resolve(&Resolvers.DynamicResolver.create_dynamic_screen/3)
    end

    @desc "Update dynamic screen"
    field :update_dynamic_screen, :dynamic_screen_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_screen_update_type))
      resolve(&Resolvers.DynamicResolver.update_dynamic_screen/3)
    end

    @desc "delete dynamic screen"
    field :delete_dynamic_screen, :dynamic_screen_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_screen_delete_type))
      resolve(&Resolvers.DynamicResolver.delete_dynamic_screen/3)
    end

    #    @desc "Get dynamic group"
    #    field :get_dynamic_groups, list_of(:dynamic_group_type) do
    #      # Resolver
    #      middleware(Middleware.Authorize, :any)
    #      arg(:input, non_null(:dynamic_group_get_type))
    #      resolve(&Resolvers.DynamicResolver.get_dynamic_groups/3)
    #    end
    @desc "create dynamic group"
    field :create_dynamic_group, list_of(:dynamic_group_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_group_input_type))
      resolve(&Resolvers.DynamicResolver.create_dynamic_group/3)
    end

    @desc "Update dynamic group"
    field :update_dynamic_group, :dynamic_group_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_group_update_type))
      resolve(&Resolvers.DynamicResolver.update_dynamic_group/3)
    end

    @desc "delete dynamic group"
    field :delete_dynamic_group, :dynamic_group_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_group_delete_type))
      resolve(&Resolvers.DynamicResolver.delete_dynamic_group/3)
    end

    @desc "attach existing dynamic group"
    field :attach_existing_dynamic_group, list_of(:attach_existing_dynamic_group_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:attach_existing_dynamic_group_input_type))
      resolve(&Resolvers.DynamicResolver.attach_existing_dynamic_group/3)
    end

    #    @desc "Get dynamic fields"
    #    field :get_dynamic_fields, list_of(:dynamic_field_type) do
    #      # Resolver
    #      middleware(Middleware.Authorize, :any)
    #      arg(:input, non_null(:dynamic_field_get_type))
    #      resolve(&Resolvers.DynamicResolver.get_dynamic_fields/3)
    #    end
    @desc "create dynamic field"
    field :create_dynamic_field, list_of(:dynamic_field_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_field_input_type))
      resolve(&Resolvers.DynamicResolver.create_dynamic_field/3)
    end

    @desc "update dynamic field"
    field :update_dynamic_field, list_of(:dynamic_field_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_field_update_type))
      resolve(&Resolvers.DynamicResolver.update_dynamic_field/3)
    end

    @desc "delete dynamic field"
    field :delete_dynamic_field, :dynamic_field_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dynamic_group_delete_type))
      resolve(&Resolvers.DynamicResolver.delete_dynamic_field/3)
    end

    @desc "create a payment dispute category"
    field :create_dispute_category, type: :dispute_category_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dispute_category_input_type))
      resolve(&Resolvers.PaymentResolver.create_dispute_category/3)
    end

    @desc "get a payment dispute category"
    field :get_dispute_category, type: :dispute_category_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dispute_category_get_type))
      resolve(&Resolvers.PaymentResolver.get_dispute_category/3)
    end

    @desc "update a payment dispute category"
    field :update_dispute_category, type: :dispute_category_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dispute_category_update_type))
      resolve(&Resolvers.PaymentResolver.update_dispute_category/3)
    end

    @desc "delete a payment dispute category"
    field :delete_dispute_category, type: :dispute_category_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dispute_category_get_type))
      resolve(&Resolvers.PaymentResolver.delete_dispute_category/3)
    end

    @desc "create a payment dispute status"
    field :create_dispute_status, type: :dispute_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dispute_status_input_type))
      resolve(&Resolvers.PaymentResolver.create_dispute_status/3)
    end

    @desc "get a payment dispute status"
    field :get_dispute_status, type: :dispute_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dispute_status_get_type))
      resolve(&Resolvers.PaymentResolver.get_dispute_status/3)
    end

    @desc "update a payment dispute status"
    field :update_dispute_status, type: :dispute_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dispute_status_update_type))
      resolve(&Resolvers.PaymentResolver.update_dispute_status/3)
    end

    @desc "delete a payment dispute status"
    field :delete_dispute_status, type: :dispute_status_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dispute_status_get_type))
      resolve(&Resolvers.PaymentResolver.delete_dispute_status/3)
    end

    @desc "get client token"
    field :get_token, :token_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:token_input_type))
      resolve(&Resolvers.PaymentResolver.get_token/3)
    end

    @desc "Get Brain tree customer"
    field :get_brain_tree_customer, :brain_tree_customer_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, :brain_tree_customer_get_type)
      resolve(&Resolvers.PaymentResolver.get_brain_tree_customer/3)
    end

    @desc "create brain tree customer"
    field :create_brain_tree_customer, :brain_tree_customer_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:brain_tree_customer_input_type))
      resolve(&Resolvers.PaymentResolver.create_brain_tree_customer/3)
    end

    @desc "update brain tree customer"
    field :update_brain_tree_customer, :brain_tree_customer_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:brain_tree_customer_input_type))
      resolve(&Resolvers.PaymentResolver.update_brain_tree_customer/3)
    end

    @desc "delete brain tree customer"
    field :delete_brain_tree_customer, :brain_tree_customer_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, :brain_tree_customer_get_type)
      resolve(&Resolvers.PaymentResolver.delete_brain_tree_customer/3)
    end

    @desc "get brain tree payment method"
    field :get_brain_tree_payment_method, :bt_payment_method_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:payment_method_get_type))
      resolve(&Resolvers.PaymentResolver.get_brain_tree_payment_method/3)
    end

    @desc "get user brain tree payment methods"
    field :get_brain_tree_payment_methods_by_user, list_of(:bt_payment_method_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:payment_method_get_type))
      resolve(&Resolvers.PaymentResolver.get_brain_tree_payment_methods_by_user/3)
    end

    @desc "create brain tree payment method"
    field :create_brain_tree_payment_method, :bt_payment_method_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:payment_method_input_type))
      resolve(&Resolvers.PaymentResolver.create_brain_tree_payment_method/3)
    end

    @desc "update brain tree payment method"
    field :update_brain_tree_payment_method, :bt_payment_method_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:payment_method_update_type))
      resolve(&Resolvers.PaymentResolver.update_brain_tree_payment_method/3)
    end

    @desc "delete brain tree payment method"
    field :delete_brain_tree_payment_method, :bt_payment_method_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:payment_method_get_type))
      resolve(&Resolvers.PaymentResolver.delete_brain_tree_payment_method/3)
    end

    @desc "get donations"
    field :get_donations, list_of(:donation_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:donation_get_type))
      resolve(&Resolvers.PaymentResolver.get_donations/3)
    end

    @desc "get brain tree transaction"
    field :get_brain_tree_transaction, :transaction_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:transaction_get_type))
      resolve(&Resolvers.PaymentResolver.get_brain_tree_transaction/3)
    end

    @desc "get brain tree transaction by"
    field :get_brain_tree_transaction_by, list_of(:transaction_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:transaction_get_by_type))
      resolve(&Resolvers.PaymentResolver.get_brain_tree_transaction_by/3)
    end

    @desc "create brain tree transaction"
    field :create_brain_tree_transaction, :transaction_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:transaction_input_type))
      resolve(&Resolvers.PaymentResolver.create_brain_tree_transaction/3)
    end

    @desc "refund brain tree transaction"
    field :refund_brain_tree_transaction, :transaction_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:transaction_refund_type))
      resolve(&Resolvers.PaymentResolver.refund_brain_tree_transaction/3)
    end

    @desc "get subscription bsp rules by slug"
    field :get_subscription_bsp_rules_by_slug, :subscription_bsp_rule_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:subscription_bsp_rule_get_by_type))
      resolve(&Resolvers.PaymentResolver.get_subscription_bsp_rules_by_slug/3)
    end

    @desc "create subscription bsp rules"
    field :create_subscription_bsp_rules, :subscription_bsp_rule_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:subscription_bsp_rule_input_type))
      resolve(&Resolvers.PaymentResolver.create_subscription_bsp_rules/3)
    end

    @desc "update subscription bsp rules"
    field :update_subscription_bsp_rules, :subscription_bsp_rule_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:subscription_bsp_rule_update_type))
      resolve(&Resolvers.PaymentResolver.update_subscription_bsp_rules/3)
    end

    @desc "delete subscription bsp rules"
    field :delete_subscription_bsp_rules, :subscription_bsp_rule_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:subscription_bsp_rule_get_type))
      resolve(&Resolvers.PaymentResolver.delete_subscription_bsp_rules/3)
    end

    @desc "create promotion price"
    field :create_promotion_price, :promotion_price_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_price_input_type))
      resolve(&Resolvers.PaymentResolver.create_promotion_price/3)
    end

    @desc "update promotion price"
    field :update_promotion_price, :promotion_price_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_price_update_type))
      resolve(&Resolvers.PaymentResolver.update_promotion_price/3)
    end

    @desc "get promotion price"
    field :get_promotion_price, :promotion_price_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_price_get_type))
      resolve(&Resolvers.PaymentResolver.get_promotion_price/3)
    end

    @desc "delete promotion price"
    field :delete_promotion_price, :promotion_price_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:promotion_price_get_type))
      resolve(&Resolvers.PaymentResolver.delete_promotion_price/3)
    end

    @desc "get available promotions"
    field :get_available_promotions, list_of(:available_promotions_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:available_promotions_get_type))
      resolve(&Resolvers.PromotionResolver.get_available_promotions/3)
    end

    @desc "create brain tree subscription"
    field :create_brain_tree_subscription, :subscription_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:subscription_input_type))
      resolve(&Resolvers.PaymentResolver.create_brain_tree_subscription/3)
    end

    @desc "get brain tree subscription"
    field :get_brain_tree_subscription, :subscription_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:subscription_get_type))
      resolve(&Resolvers.PaymentResolver.get_brain_tree_subscription/3)
    end

    @desc "get brain tree subscription by"
    field :get_brain_tree_subscription_by, list_of(:subscription_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:subscription_get_by_type))
      resolve(&Resolvers.PaymentResolver.get_brain_tree_subscription_by/3)
    end

    @desc "retry charge brain tree subscription"
    field :retry_charge_brain_tree_subscription, list_of(:subscription_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:brain_tree_subscription_retry_charge_type))
      resolve(&Resolvers.PaymentResolver.retry_charge_brain_tree_subscription/3)
    end

    @desc "update brain tree subscription"
    field :update_brain_tree_subscription, :subscription_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:subscription_update_type))
      resolve(&Resolvers.PaymentResolver.update_brain_tree_subscription/3)
    end

    @desc "cancel brain tree subscription"
    field :cancel_brain_tree_subscription, :subscription_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:subscription_cancel_type))
      resolve(&Resolvers.PaymentResolver.cancel_brain_tree_subscription/3)
    end

    @desc "get brain tree merchant account"
    field :get_brain_tree_merchant_account, :merchant_account_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:merchant_account_get_type))
      resolve(&Resolvers.PaymentResolver.get_brain_tree_merchant_account/3)
    end

    @desc "create brain tree merchant account"
    field :create_brain_tree_merchant_account, :merchant_account_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:merchant_account_input_type))
      resolve(&Resolvers.PaymentResolver.create_brain_tree_merchant_account/3)
    end

    @desc "update brain tree merchant account"
    field :update_brain_tree_merchant_account, :merchant_account_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:merchant_account_update_type))
      resolve(&Resolvers.PaymentResolver.update_brain_tree_merchant_account/3)
    end

    @desc "create credit card verification"
    field :create_credit_card_verification, :credit_card_verification_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:credit_card_verification_input_type))
      #      resolve(&Resolvers.PaymentResolver.create_credit_card_verification/3)
    end

    @desc "get brain tree paypal account"
    field :get_brain_tree_paypal_account, :paypal_account_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_account_get_type))
      #      resolve(&Resolvers.PaymentResolver.get_brain_tree_paypal_account/3)
    end

    @desc "list hyper wallet users"
    field :list_hyper_wallet_users, list_of(:hyper_wallet_user_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:hyper_wallet_user_input_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.list_hyper_wallet_users/3)
    end

    @desc "create hyper wallet user"
    field :create_hyper_wallet_user, :hyper_wallet_user_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:hyper_wallet_user_input_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.create_hyper_wallet_user/3)
    end

    @desc "get hyper wallet users"
    field :get_hyper_wallet_users, list_of(:hyper_wallet_user_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:hyper_wallet_user_get_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.get_hyper_wallet_users/3)
    end

    @desc "update hyper wallet user"
    field :update_hyper_wallet_user, :hyper_wallet_user_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:hyper_wallet_user_update_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.update_hyper_wallet_user/3)
    end

    @desc "list all hyper wallet transfer methods of a specific user"
    field :list_all_hyper_wallet_transfer_methods_of_user,
          list_of(:hyper_wallet_transfer_method_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)

      resolve(
        &Resolvers.HyperWalletPaymentResolver.list_all_hyper_wallet_transfer_methods_of_user/3
      )
    end

    @desc "get specific hyper wallet transfer method of a specific user"
    field :get_hyper_wallet_transfer_method, :hyper_wallet_transfer_method_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:hyper_wallet_transfer_method_get_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.get_hyper_wallet_transfer_method/3)
    end

    @desc "get hyper wallet transfer method fields"
    field :get_hyper_wallet_transfer_method_fields,
          list_of(:hyper_wallet_transfer_method_fields_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:hyper_wallet_transfer_method_fields_get_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.get_hyper_wallet_transfer_method_fields/3)
    end

    @desc "get hyper wallet currencies and transfer method"
    field :get_hyper_wallet_currencies_and_transfer_methods,
          list_of(:hyper_wallet_currencies_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:hyper_wallet_currencies_get_type))

      resolve(
        &Resolvers.HyperWalletPaymentResolver.get_hyper_wallet_currencies_and_transfer_methods/3
      )
    end

    @desc "create hyper wallet transfer method"
    field :create_hyper_wallet_transfer_method, :hyper_wallet_transfer_method_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:hyper_wallet_transfer_method_input_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.create_hyper_wallet_transfer_method/3)
    end

    @desc "update hyper wallet transfer method of a specific user"
    field :update_hyper_wallet_transfer_method, :hyper_wallet_transfer_method_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:hyper_wallet_transfer_method_update_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.update_hyper_wallet_transfer_method/3)
    end

    @desc "list hyper wallet payments"
    field :list_hyper_wallet_payments, list_of(:hyper_wallet_transaction_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:hyper_wallet_user_input_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.list_hyper_wallet_payments/3)
    end

    @desc "create hyper wallet payment"
    field :create_hyper_wallet_payment, :hyper_wallet_transaction_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:hyper_wallet_transaction_input_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.create_hyper_wallet_payment/3)
    end

    @desc "get hyper wallet payment"
    field :get_hyper_wallet_payment, :hyper_wallet_transaction_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:hyper_wallet_transaction_get_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.get_hyper_wallet_payment/3)
    end

    @desc "create hyper wallet transfer"
    field :create_hyper_wallet_transfer, :hyper_wallet_transfer_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:hyper_wallet_transfer_input_type))
      resolve(&Resolvers.HyperWalletPaymentResolver.create_hyper_wallet_transfer/3)
    end

    @desc "get paypal access token"
    field :get_paypal_access_token, :paypal_access_token_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:paypal_access_token_input_type))
      resolve(&Resolvers.PaypalPaymentResolver.get_paypal_access_token/3)
    end

    @desc "create seller account for paypal or hyper wallet"
    field :create_seller_account, :seller_account_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:seller_account_input_type))
      resolve(&Resolvers.PaypalPaymentResolver.create_seller_account/3)
    end

    @desc "get seller accounts by user"
    field :get_paypal_seller_accounts_by_user, list_of(:paypal_seller_account_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:paypal_seller_account_get_type))
      resolve(&Resolvers.PaypalPaymentResolver.get_seller_accounts_by_user/3)
    end

    @desc "delete paypal seller account"
    field :delete_paypal_seller_account, :paypal_seller_account_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_seller_account_delete_type))
      resolve(&Resolvers.PaypalPaymentResolver.delete_paypal_seller_account/3)
    end

    @desc "update paypal seller account"
    field :update_paypal_seller_account, :paypal_seller_account_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_seller_account_update_type))
      resolve(&Resolvers.PaypalPaymentResolver.update_paypal_seller_account/3)
    end

    @desc "create paypal order"
    field :create_paypal_order, :paypal_order_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_order_input_type))
      resolve(&Resolvers.PaypalPaymentResolver.create_paypal_order/3)
    end

    @desc "Authorize Payment for order"
    field :authorize_payment, :paypal_order_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:authorize_payment_input_type))
      resolve(&Resolvers.PaypalPaymentResolver.authorize_payment/3)
    end

    @desc "capture paypal order"
    field :capture_paypal_order, :paypal_order_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:action_on_paypal_order_input_type))
      resolve(&Resolvers.PaypalPaymentResolver.capture_paypal_order/3)
    end

    @desc "get paypal order"
    field :get_paypal_order, :paypal_order_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:action_on_paypal_order_input_type))
      resolve(&Resolvers.PaypalPaymentResolver.get_paypal_order/3)
    end

    #
    #    @desc "disburse paypal order"
    #    field :disburse_paypal_order, :paypal_order_type do
    #      # Resolver
    #      middleware(Middleware.Authorize, :any)
    #      arg(:input, non_null(:disburse_paypal_order_input_type))
    #      resolve(&Resolvers.PaypalPaymentResolver.disburse_paypal_order/3)
    #    end

    @desc "create paypal payout"
    field :create_paypal_payout, :json do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_payout_input_type))
      resolve(&Resolvers.PaypalPaymentResolver.create_paypal_payout/3)
    end

    @desc "create paypal product"
    field :create_paypal_product, :paypal_product_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_product_input_type))
      resolve(&Resolvers.PaypalPaymentResolver.create_paypal_product/3)
    end

    @desc "create paypal plan"
    field :create_paypal_plan, :paypal_plan_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_plan_input_type))
      resolve(&Resolvers.PaypalPaymentResolver.create_paypal_plan/3)
    end

    @desc "update paypal plan"
    field :update_paypal_plan, :paypal_plan_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_plan_update_type))
      resolve(&Resolvers.PaypalPaymentResolver.update_paypal_plan/3)
    end

    @desc "get paypal plans by country"
    field :paypal_subscription_plans_by_country, list_of(:paypal_featured_plan_type) do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_plan_get_by_country_type))
      resolve(&Resolvers.PaypalPaymentResolver.paypal_subscription_plans_by_country/3)
    end

    @desc "create paypal subscription"
    field :create_paypal_subscription, :paypal_subscription_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_subscription_input_type))
      resolve(&Resolvers.PaypalPaymentResolver.create_paypal_subscription/3)
    end

    @desc "update paypal subscription"
    field :update_paypal_subscription, :paypal_subscription_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_subscription_update_type))
      resolve(&Resolvers.PaypalPaymentResolver.update_paypal_subscription/3)
    end

    @desc "get paypal subscription by business"
    field :paypal_subscription_by_business, list_of(:paypal_subscription_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_subscription_get_by_business_type))
      resolve(&Resolvers.PaypalPaymentResolver.paypal_subscription_by_business/3)
    end

    @desc "refresh paypal access token"
    field :refresh_token, :paypal_access_attribute_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.PaypalPaymentResolver.refresh_token/3)
    end

    @desc "create cash payment"
    field :create_cash_payment, :cash_payment_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cash_payment_input_type))
      resolve(&Resolvers.CashPaymentResolver.create_cash_payment/3)
    end

    @desc "Get cash payment by Invoice"
    field :get_cash_payment_by_invoice, :cash_payment_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cash_payment_get_type))
      resolve(&Resolvers.CashPaymentResolver.get_cash_payment_by_invoice/3)
    end

    @desc "generate cash payment"
    field :generate_cash_payment, :cash_payment_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cash_payment_generate_type))
      resolve(&Resolvers.CashPaymentResolver.generate_cash_payment/3)
    end

    @desc "adjust cash payment"
    field :adjust_cash_payment, :cash_payment_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cash_payment_adjust_type))
      resolve(&Resolvers.CashPaymentResolver.adjust_cash_payment/3)
    end

    @desc "update cash payment"
    field :update_cash_payment, :cash_payment_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cash_payment_update_type))
      resolve(&Resolvers.CashPaymentResolver.update_cash_payment/3)
    end

    @desc "get cmr paid payments"
    field :get_cmr_paid_payments, :cmr_paid_payment_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, :cmr_paid_payment_get_type)
      resolve(&Resolvers.PaymentResolver.get_cmr_paid_payments/3)
    end

    @desc "get bsp paid payments"
    field :get_bsp_paid_payments, list_of(:payment_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bsp_paid_payment_get_type))
      resolve(&Resolvers.PaymentResolver.get_bsp_paid_payments/3)
    end

    @desc "get payment for cash and cheque notifications"
    field :get_payment, :payment_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:payment_get_type))
      resolve(&Resolvers.PaymentResolver.get_payment/3)
    end

    @desc "get bsp earning"
    field :get_bsp_earning, :bsp_earning_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bsp_payment_get_type))
      resolve(&Resolvers.PaymentResolver.get_bsp_earning/3)
    end

    @desc "get tudo earning"
    field :get_tudo_earning, list_of(:payment_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      #      arg(:input, non_null(:bsp_payment_get_type))
      resolve(&Resolvers.PaymentResolver.get_tudo_earning/3)
    end

    @desc "upload icons"
    field :upload_icons, list_of(:json) do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      arg(:input, list_of(:file))
      resolve(&Resolvers.FileResolver.upload_icons/3)
    end

    @desc "get icons"
    field :get_icons, list_of(:json) do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      arg(:input, list_of(:icon))
      resolve(&Resolvers.FileResolver.get_icons/3)
    end

    @desc "get a job requests"
    field :get_job_request_by, list_of(:job_request_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_request_get_by_type))
      resolve(&Resolvers.JobResolver.get_job_request_by/3)
    end

    @desc "get a job requests by id"
    field :get_job_request, :job_request_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_request_get_type))
      resolve(&Resolvers.JobResolver.get_job_request/3)
    end

    @desc "create a job category"
    field :create_job_category, list_of(:job_category_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_category_input_type))
      resolve(&Resolvers.JobResolver.create_job_category/3)
    end

    @desc "get a job category"
    field :get_job_category, list_of(:job_category_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_category_get_type))
      resolve(&Resolvers.JobResolver.get_job_category/3)
    end

    @desc "update a job_category"
    field :update_job_category, list_of(:job_category_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_category_update_type))
      resolve(&Resolvers.JobResolver.update_job_category/3)
    end

    @desc "delete a job_category"
    field :delete_job_category, list_of(:job_category_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_category_get_type))
      resolve(&Resolvers.JobResolver.delete_job_category/3)
    end

    @desc "get time and distance between locations"
    field :get_distance_and_time, :json do
      # Resolver
      #      middleware(Middleware.Authorize, :any)
      arg(:input, list_of(:distance_and_time_get_type))
      resolve(&Resolvers.JobResolver.get_distance_and_time/3)
    end

    @desc "create a job status"
    field :create_job_status, list_of(:job_status_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_status_input_type))
      resolve(&Resolvers.JobResolver.create_job_status/3)
    end

    @desc "get a job status"
    field :get_job_status, list_of(:job_status_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_status_get_type))
      resolve(&Resolvers.JobResolver.get_job_status/3)
    end

    @desc "update a job status"
    field :update_job_status, list_of(:job_status_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_status_update_type))
      resolve(&Resolvers.JobResolver.update_job_status/3)
    end

    @desc "delete a job status"
    field :delete_job_status, list_of(:job_status_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:job_status_get_type))
      resolve(&Resolvers.JobResolver.delete_job_status/3)
    end

    @desc "create a dart error"
    field :create_dart_error, list_of(:dart_error_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dart_error_input_type))
      resolve(&Resolvers.ErrorResolver.create_dart_error/3)
    end

    @desc "get a dart error"
    field :get_dart_error, :dart_error_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dart_error_get_type))
      resolve(&Resolvers.ErrorResolver.get_dart_error/3)
    end

    #    @desc "update a dart error"
    #    field :update_dart_error, :dart_error_type do
    #      # Resolver
    #      middleware(Middleware.Authorize, :any)
    #      arg(:input, non_null(:dart_error_update_type))
    #      resolve(&Resolvers.ErrorResolver.update_dart_error/3)
    #    end
    @desc "delete a dart error"
    field :delete_dart_error, :dart_error_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:dart_error_get_type))
      resolve(&Resolvers.ErrorResolver.delete_dart_error/3)
    end

    @desc "create_tudo_settings"
    field :create_tudo_setting, :tudo_setting_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:tudo_setting_input_type))
      resolve(&Resolvers.SettingResolver.create_tudo_settings/3)
    end

    @desc "update_tudo_settings"
    field :update_tudo_setting, :tudo_setting_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:tudo_setting_update_type))
      resolve(&Resolvers.SettingResolver.update_tudo_settings/3)
    end

    @desc "delete_tudo_settings"
    field :delete_tudo_setting, :tudo_setting_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:tudo_setting_delete_type))
      resolve(&Resolvers.SettingResolver.delete_tudo_settings/3)
    end

    # for now we are using create_cashfree_order_and_pay API. We are using the separate
    # create_order API and order_apy API
    @desc "create cashfree order and pay"
    field :create_cashfree_order_and_pay, :cashfree_order_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:create_cashfree_order_and_pay_input_type))
      resolve(&Resolvers.CashfreeResolver.create_cashfree_order_and_pay/3)
    end

    @desc "create cashfree order"
    field :create_cashfree_order, :cashfree_order_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cashfree_order_input_type))
      resolve(&Resolvers.CashfreeResolver.create_cashfree_order/3)
    end

    @desc "update payment when order pay"
    field :update_payment_when_order_pay, :cashfree_order_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:get_cashfree_order_input_type))
      resolve(&Resolvers.CashfreeResolver.update_payment_when_order_pay/3)
    end

    @desc "create cashfree plan"
    field :create_cashfree_plan, :paypal_plan_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_plan_input_type))
      resolve(&Resolvers.CashfreeResolver.create_cashfree_plan/3)
    end

    @desc "create cashfree subscription"
    field :create_cashfree_subscription, :paypal_subscription_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:paypal_subscription_input_type))
      resolve(&Resolvers.CashfreeResolver.create_cashfree_subscription/3)
    end

    @desc "create beneficiary for cashfree"
    field :create_beneficiary, :beneficiary_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:beneficiary_input_type))
      resolve(&Resolvers.CashfreeResolver.create_beneficiary/3)
    end

    @desc "List beneficiary for cashfree"
    field :list_beneficiary, list_of(:list_beneficiary_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.CashfreeResolver.list_beneficiary/3)
    end

    @desc "create payout for cashfree"
    field :cashfree_paypout, :json do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:cashfree_payout_input_type))
      resolve(&Resolvers.CashfreeResolver.create_cashfree_payout/3)
    end

    @desc "delete beneficiary for cashfree"
    field :delete_beneficiary, :beneficiary_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:delete_beneficiary_input_type))
      resolve(&Resolvers.CashfreeResolver.delete_beneficiary/3)
    end

    @desc "check if a user has a paid subscription"
    field :get_subscriptions_by_user, list_of(:paypal_subscription_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:user_subscription_input_type))
      resolve(&Core.PaypalPayments.check_user_subscriptions_exist?/3)
    end

    @desc "create product warranty"
    field :create_product_warranty, list_of(:product_warranty_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:product_warranty_input_type))
      resolve(&Resolvers.ProductWarrantyResolver.create_product_warranty/3)
    end

    @desc "update product warranty"
    field :update_product_warranty, :product_warranty_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:update_product_warranty_input_type))
      resolve(&Resolvers.ProductWarrantyResolver.update_product_warranty/3)
    end

    @desc "delete product warranty"
    field :delete_product_warranty, :product_warranty_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:delete_product_warranty_input_type))
      resolve(&Resolvers.ProductWarrantyResolver.delete_product_warranty/3)
    end

    @desc "list manufacturer_names"
    field :product_manufacturers, list_of(:paginate_manufacturer_names) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:manufacturer_names_input_type))
      resolve(&Resolvers.ProductWarrantyResolver.product_manufacturers/3)
    end

    @desc "delete email templates"
    field :delete_email_templates, :email_template_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:delete_email_template_input_type))
      resolve(&Resolvers.EmailTemplateResolver.delete_email_templates/3)
    end

    @desc "create_bsp_email_template"
    field :create_bsp_email_template, :bsp_email_template_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bsp_email_template_input_type))
      resolve(&Resolvers.BspEmailTemplateResolver.create_bsp_email_template/3)
    end

    @desc "update_bsp_email_template"
    field :update_bsp_email_template, :bsp_email_template_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bsp_email_template_update_type))
      resolve(&Resolvers.BspEmailTemplateResolver.update_bsp_email_template/3)
    end

    @desc "Delete bsp email template"
    field :delete_bsp_email_template, :bsp_email_template_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:bsp_email_template_delete_type))
      resolve(&Resolvers.BspEmailTemplateResolver.delete_bsp_email_template/3)
    end

    @desc "create tudo charges"
    field :create_tudo_charges, :tudo_charges_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:tudo_charges_input_type))
      resolve(&Resolvers.TudoChargesResolver.create_tudo_charges/3)
    end

    @desc "update tudo charges"
    field :update_tudo_charges, :tudo_charges_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:tudo_charges_update_type))
      resolve(&Resolvers.TudoChargesResolver.update_tudo_charges/3)
    end

    @desc "delete tudo charges"
    field :delete_tudo_charges, :tudo_charges_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:tudo_charges_delete_type))
      resolve(&Resolvers.TudoChargesResolver.delete_tudo_charges/3)
    end

    @desc "get tudo charges"
    field :get_tudo_charges, list_of(:tudo_charges_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.TudoChargesResolver.get_tudo_charges/2)
    end

    @desc "create product"
    field :create_product, :product_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:product_input_type))
      resolve(&Resolvers.ProductResolver.create_product/3)
    end

    @desc "list product"
    field :list_product, list_of(:product_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:list_product_input_type))
      resolve(&Resolvers.ProductResolver.list_product/3)
    end

    @desc "delete product"
    field :delete_product, :product_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:delete_product_input_type))
      resolve(&Resolvers.ProductResolver.delete_product/3)
    end

    @desc "update product"
    field :update_product, :product_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:update_product_input_type))
      resolve(&Resolvers.ProductResolver.update_product/3)
    end

    @desc "list product category"
    field :list_product_category, list_of(:product_category_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.ProductResolver.list_product_category/2)
    end

    @desc "create order"
    field :create_order, :order_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:order_input_type))
      resolve(&Resolvers.OrderResolver.create_order/3)
    end

    @desc "update order"
    field :update_order, :order_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:update_order_input_type))
      resolve(&Resolvers.OrderResolver.update_order/3)
    end

    @desc "get order"
    field :get_order, list_of(:order_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:get_order_input_type))
      resolve(&Resolvers.OrderResolver.get_order/3)
    end

    @desc "create warehouse"
    field :create_warehouse, :warehouse_type do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, non_null(:create_warehouse_input_type))
      resolve(&Resolvers.WarehouseResolver.create_warehouse/3)
    end
  end

  subscription do
    field :create_user, type: :user_type do
      config(fn _, _ ->
        {:ok, topic: true}
      end)
    end

    field :job_socket, type: :job_type do
      config(fn _, _ ->
        {:ok, topic: true}
      end)
    end

    field :meta_bsp_socket, type: :meta_bsp_type do
      config(fn _, _ ->
        {:ok, topic: "*"}
      end)
    end

    field :meta_cmr_socket, type: :meta_cmr_type do
      config(fn _, _ ->
        {:ok, topic: "*"}
      end)
    end
  end
end
