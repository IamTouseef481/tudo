defmodule CoreWeb.Helpers.AdminNotificationSettingsHelper do
  #   Core.Notifications.AdminNotificationSettingsHelper

  @moduledoc false
  alias Core.Notifications

  def check_admin_email_permission(role, event) do
    case event do
      "create_job_confirmed_for_cmr" ->
        Notifications.get_admin_email_setting_for_cmr("create_job_confirmed")

      "create_job_confirmed_for_bsp" ->
        Notifications.get_admin_email_setting_for_bsp("create_job_confirmed")

      "create_job_pending_for_cmr" ->
        Notifications.get_admin_email_setting_for_cmr("create_job_pending")

      "create_job_pending_for_bsp" ->
        Notifications.get_admin_email_setting_for_bsp("create_job_pending")

      "cancel_job_for_cmr" ->
        Notifications.get_admin_email_setting_for_cmr("cancel_job")

      "cancel_job_for_bsp" ->
        Notifications.get_admin_email_setting_for_bsp("cancel_job")

      "invoice_ready_for_cmr" ->
        Notifications.get_admin_email_setting_for_cmr("job_invoice")

      "adjust_invoice_for_bsp" ->
        Notifications.get_admin_email_setting_for_bsp("adjust_invoice")

      "adjusted_invoice_for_cmr" ->
        Notifications.get_admin_email_setting_for_cmr("adjusted_invoice")

      "raise_dispute_for_bsp" ->
        Notifications.get_admin_email_setting_for_bsp("raise_dispute")

      "manage_dispute_for_cmr" ->
        Notifications.get_admin_email_setting_for_cmr("manage_dispute")

      "reschedule_job_for_bsp" ->
        Notifications.get_admin_email_setting_for_bsp("reschedule_job")

      "reschedule_job_for_cmr" ->
        Notifications.get_admin_email_setting_for_cmr("reschedule_job")

      "invite_employee" ->
        Notifications.get_admin_email_setting_for_cmr(event)

      #        common for both cmr and bsps, need to write new query to handle these
      "payment_made" ->
        get_admin_email_setting_for(role, event)

      "reject_job_changes_for_bsp" ->
        get_admin_email_setting_for(role, event)

      "accept_job_changes_for_bsp" ->
        get_admin_email_setting_for(role, event)

      "update_platform_terms" ->
        get_admin_email_setting_for(role, event)

      #      "invite_cmr" -> get_admin_email_setting_for(role, event)
      #      "registration_activation" -> get_admin_email_setting_for(role, event)
      #      "forget_password" -> get_admin_email_setting_for(role, event)
      _ ->
        true
    end
  end

  defp get_admin_email_setting_for(role, event) do
    if role in ["cmr", nil, ""] do
      Notifications.get_admin_email_setting_for_cmr(event)
    else
      Notifications.get_admin_email_setting_for_bsp(event)
    end
  end

  def check_admin_notification_permission(role, event) do
    case event do
      "create_job_confirmed_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("create_job_confirmed")

      "create_job_confirmed_for_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("create_job_confirmed")

      "create_job_pending_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("create_job_pending")

      "create_job_pending_for_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("create_job_pending")

      "accept_job_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("accept_job_changes")

      "accept_job_changes_for_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("accept_job_changes")

      "reject_job_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("reject_changes")

      "reject_job_changes_for_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("reject_changes")

      "cancel_job_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("cancel_job")

      "cancel_job_for_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("cancel_job")

      "reschedule_job_for_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("reschedule_job")

      "reschedule_job_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("reschedule_job")

      "agent_reassign_job_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("agent_reassign_job")

      "reassign_job_for_bsp_emp" ->
        Notifications.get_admin_notification_setting_for_bsp("agent_reassign_job")

      "invoice_ready_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("job_invoice")

      "adjust_invoice_for_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("adjust_invoice")

      "adjusted_invoice_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("adjusted_invoice")

      "raise_dispute_for_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("raise_dispute")

      "manage_dispute_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("manage_dispute")

      "on_board_walk_in_cmr_near_appointment" ->
        Notifications.get_admin_notification_setting_for_cmr("on_board_walk_in_near_appointment")

      "bsp_on_boards_appointment" ->
        Notifications.get_admin_notification_setting_for_bsp("on_board_walk_in_near_appointment")

      "in_home_on_demand_bsp_near_appointment" ->
        Notifications.get_admin_notification_setting_for_cmr(
          "on_board_in_home_on_demand_near_appointment"
        )

      "in_home_on_demand_bsp_near_appointment_cmr_bsp_initiates_on_board_action" ->
        Notifications.get_admin_notification_setting_for_bsp(
          "on_board_in_home_on_demand_near_appointment"
        )

      "bsp_sends_employment_invitation_to_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("invite_employee")

      "cmr_accepts_employment_invitation_to_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("employee_invitation_accept")

      "cash_payment_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("cash_payment")

      "cash_payment_for_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("cash_payment")

      "cheque_payment_for_cmr" ->
        Notifications.get_admin_notification_setting_for_cmr("cheque_payment")

      "cheque_payment_for_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("cheque_payment")

      "new_bid_request_to_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("new_bid_request")

      "bid_reject_to_bsp" ->
        Notifications.get_admin_notification_setting_for_bsp("bid_reject")

      #        common for both cmr and bsps
      "appointment_alert_12_hrs_earlier" ->
        get_admin_notification_setting_for(role, event)

      "appointment_alert_2_hrs_earlier" ->
        get_admin_notification_setting_for(role, event)

      "appointment_alert_30_mins_earlier" ->
        get_admin_notification_setting_for(role, event)

      "appointment_alert_5_mins_earlier" ->
        get_admin_notification_setting_for(role, event)

      "payment_made" ->
        get_admin_notification_setting_for(role, event)

      "update_platform_terms" ->
        get_admin_notification_setting_for(role, event)

      "invite_cmr" ->
        get_admin_notification_setting_for(role, event)

      "call" ->
        get_admin_notification_setting_for(role, event)

      _ ->
        true
    end
  end

  defp get_admin_notification_setting_for(role, event) do
    if role in ["cmr", nil, ""] do
      Notifications.get_admin_notification_setting_for_cmr(event)
    else
      Notifications.get_admin_notification_setting_for_bsp(event)
    end
  end
end
