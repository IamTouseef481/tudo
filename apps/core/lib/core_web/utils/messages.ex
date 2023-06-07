defmodule CoreWeb.Utils.Messages do
  @moduledoc false
  import CoreWeb.Utils.Errors
  alias CoreWeb.Workers.NotificationEmailsWorker, as: Emails

  @common_error ["can't get push notification message!"]

  #    our pattern strings in message body (e.g job_id) and keys of params sending as last argument from enqeue (job_id)should be same
  # this module was used to fetch the notifications. But now we are using send_in_blue api to get the notifications.
  #  @push_notification_messages %{
  #    en: [
  #      %{
  #        create_job_pending_for_cmr: %{
  #          title: "",
  #          description: "!!THANK YOU!! - Your {{service_type}} Appointment # {{job_id}} has been created and waiting for service provider {{bsp_profile_name}} approval."
  #        }
  #      },
  #      %{
  #        create_job_pending_for_bsp: %{
  #          title: "",
  #          description: "!!ACTION REQUIRED!! Congratulations you are scheduled for a new {{service_type}} Appointment # {{job_id}} assigned to {{emp_profile_name}} with {{cmr_profile_name}}"
  #        }
  #      },
  #      %{
  #        create_job_confirmed_for_cmr: %{
  #          title: "",
  #          description: "!!THANK YOU!!- Your {{service_type}} Appointment  # {{job_id}} has been created, scheduled and assigned to service provider {{bsp_profile_name}}."
  #        }
  #      },
  #      %{
  #        create_job_confirmed_for_bsp: %{
  #          title: "",
  #          description: "!!NEW APPOINTMENT!!- Congratulations you are scheduled for a new {{service_type}} Appointment  # {{job_id}} assigned to {{emp_profile_name}} with {{cmr_profile_name}}."
  #        }
  #      },
  #      %{
  #        accept_job_for_cmr: %{
  #          title: "",
  #          description: "!!ACCEPTED!!- Your {{service_type}} Appointment  # {{job_id}} changes accepted, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        accept_job_changes_for_bsp: %{
  #          title: "",
  #          description: "!!ACCEPTED!!- Your {{service_type}} Appointment  # {{job_id}} changes accepted, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        reject_job_for_cmr: %{
  #          title: "",
  #          description: "!!REJECTED!!- {{service_type}} Appointment  # {{job_id}} changes have been rejected and the good news is your original appointment intact."
  #        }
  #      },
  #      %{
  #        reject_job_changes_for_bsp: %{
  #          title: "",
  #          description: "!!REJECTED!!- {{service_type}} Appointment  # {{job_id}} changes have been rejected and the good news is your original appointment intact."
  #        }
  #      },
  #      %{
  #        cancel_job_for_cmr: %{
  #          title: "",
  #          description: "!!CANCELLED - Your Action Required!! {{service_type}} Appointment  # {{job_id}} has been CANCELLED, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        cancel_job_for_bsp: %{
  #          title: "",
  #          description: "!!CANCELLED - Your Action Required!! {{service_type}} Appointment  # {{job_id}} has been CANCELLED, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        reschedule_job_for_bsp: %{
  #          title: "",
  #          description: "!!RESCHEDULE - Your action REQUIRED!! {{service_type}} Appointment  # {{job_id}} has been Re-scheduled with
  #           Business Service Provider {{bsp_branch_profile_name}}, please verify and Accept OR Reject the changes."
  #        }
  #      },
  #      %{
  #        reschedule_job_for_cmr: %{
  #          title: "",
  #          description: "!!RESCHEDULE - Your action REQUIRED!! {{service_type}} Appointment  # {{job_id}} has been Re-scheduled with
  #           Business Service Provider {{bsp_branch_profile_name}}, please verify and Accept OR Reject the changes."
  #        }
  #      },
  #      %{
  #        agent_reassign_job_for_cmr: %{
  #          title: "",
  #          description: "!!CHANGES - No Action needed!! FYI. Agent assignment for {{service_type}} Appointment  # {{job_id}} has been updated."
  #        }
  #      },
  #      %{
  #        agent_reassign_job_for_bsp_emp: %{
  #          title: "",
  #          description: "!!CHANGES - Action REQUIRED!! {{service_type}} Appointment  # {{job_id}} has been assigned to Emp#
  #            {{current_employee_id}} from Emp# {{previous_employee_id}}. Please note and verify and plan."
  #        }
  #      },
  #      %{
  #        invoice_ready_for_cmr: %{
  #          title: "",
  #          description: "!!INVOICED BILLED - Your action REQUIRED!! - Your {{service_type}} Appointment  # {{job_id}}
  #            has been completed and ready for PAYMENT of  {{invoice_amount}} and appreciate your quick payment."
  #        }
  #      },
  #      %{
  #        adjust_invoice_for_bsp: %{
  #          title: "",
  #          description: "!!ADJUST INVOICE - Your action REQUIRED!! - Consumer requested an adjustment in Invoice# {{invoice_id}}. Act fast to get paid."
  #        }
  #      },
  #      %{
  #        adjusted_invoice_for_cmr: %{
  #          title: "",
  #          description: "!!INVOICE ADJUSTED - Your action REQUIRED!! - Your {{service_type}} Appointment# {{job_id}} has been
  #            completed and ready for PAYMENT of  {{invoice_amount}} and appreciate your quick payment."
  #        }
  #      },
  #      %{
  #        raise_dispute_for_bsp: %{
  #          title: "",
  #          description: "!!DISPUTE RAISED - Your action REQUIRED!! - Consumer requested to resolve issue with {{service_type}}
  #           Appointment  # {{job_id}} and  invoice amount:  {{invoice_amount}}. Act fast to resolve the dispute."
  #        }
  #      },
  #      %{
  #        manage_dispute_for_cmr: %{
  #          title: "",
  #          description: "!!DISPUTE RESOLVED - Your action REQUIRED!! - Dispute on {{service_type}} Appointment  # {{job_id}} has been
  #           resolved and revised invoice amount:  {{invoice_amount}} ready for payment, appreciate your prompt payment."
  #        }
  #      },
  #      %{
  #        on_board_walk_in_cmr_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        bsp_on_boards_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        walk_in_cmr_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        in_home_on_demand_bsp_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Business Provider for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{employee_id}}"
  #        }
  #      },
  #      %{
  #        in_home_on_demand_bsp_near_appointment_cmr_bsp_initiates_on_board_action: %{
  #          title: "",
  #          description: "!INFORMATION!! Business Provider for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{employee_id}}"
  #        }
  #      },
  #      %{
  #        appointment_alert_12_hrs_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 12 hours."
  #        }
  #      },
  #      %{
  #        appointment_alert_2_hrs_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 2 hours."
  #        }
  #      },
  #      %{
  #        appointment_alert_30_mins_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 30 minutes."
  #        }
  #      },
  #      %{
  #        appointment_alert_5_mins_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 5 minutes."
  #        }
  #      },
  #      %{
  #        payment_made: %{
  #          title: "",
  #          description: "!!PAYMENT PROCESSED!! - Your payment  {{invoice_amount}} for {{service_type}}
  #            Appointment  # {{job_id}} has been processed successfully, thank you and looking forward to doing business with you again."
  #        }
  #      },
  #      %{
  #        cash_payment_made: %{
  #          title: "",
  #          description: "!!Cash PAID!! - Cash for {{service_type}} Appointment# {{job_id}} has been paid, thank you and looking forward to doing business with you again."
  #        }
  #      },
  #      %{
  #        bsp_sends_employment_invitation_to_cmr: %{
  #          title: "Employee Enrollment",
  #          description: "!!NEW EMPLOYMENT, ACTION NEEDED!! Welcome onboard for your employment offer from {{bsp_profile_name}}. Click here for next steps."
  #        }
  #      },
  #      %{
  #        cmr_accepts_employment_invitation_to_bsp: %{
  #          title: "Employee Enrollment Accepted",
  #          description: "ACTION REQUIRED - New Employee {{cmr_profile_name}} accepted your employment offer and ready to start. To verify and activate, Click here for next steps."
  #        }
  #      },
  #      %{
  #        reset_password_for_cmr: %{
  #          title: "Reset Password",
  #          description: "!!ACCOUNT UPDATE - Your action REQUIRED!! An email sent with update Instructions."
  #        }
  #      },
  #    %{
  #        update_platform_terms: %{
  #          title: "Platform Terms Updated",
  #          description: "Platform Terms Updated"
  #        }
  #      },
  #    %{
  #      new_bid_request_to_bsp: %{
  #        title: "Bid Request",
  #        description: "(B)ACTION REQUIRED, New Bid Request {{bid_id}} for {{job_title}} received, respond fact to get accepted."
  #      }
  #    }
  #    ]
  #  ,
  #    es: [
  #      %{
  #        create_job_pending_for_cmr: %{
  #          title: "",
  #          description: "!!¡¡GRACIAS!! - Se ha creado su cita de {{service_type}} ID: # {{job_id}} y está esperando la aprobación del proveedor de servicios {{bsp_profile_name}}."
  #        }
  #      },
  #      %{
  #        create_job_pending_for_bsp: %{
  #          title: "",
  #          description: "!!¡¡ACCIÓN REQUERIDA!! ¡Felicitaciones, está programado para una nueva cita de {{service_type}}  # {{job_id}} asignada a {{emp_profile_name}} con Consumer_profile_name"
  #        }
  #      },
  #      %{
  #        create_job_confirmed_for_cmr: %{
  #          title: "",
  #          description: "!!THANK YOU!!- Your {{service_type}} Appointment  # {{job_id}} has been created, scheduled and assigned to service provider {{bsp_profile_name}}."
  #        }
  #      },
  #      %{
  #        create_job_confirmed_for_bsp: %{
  #          title: "",
  #          description: "!!NEW APPOINTMENT!!- Congratulations you are scheduled for a new {{service_type}} Appointment  # {{job_id}} assigned to {{emp_profile_name}} with {{cmr_profile_name}}."
  #        }
  #      },
  #      %{
  #        accept_job_for_cmr: %{
  #          title: "",
  #          description: "!!ACCEPTED!!- Your {{service_type}} Appointment  # {{job_id}} changes accepted, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        accept_job_changes_for_bsp: %{
  #          title: "",
  #          description: "!!ACCEPTED!!- Your {{service_type}} Appointment  # {{job_id}} changes accepted, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        reject_job_for_cmr: %{
  #          title: "",
  #          description: "!!REJECTED!!- {{service_type}} Appointment  # {{job_id}} changes have been rejected and the good news is your original appointment intact."
  #        }
  #      },
  #      %{
  #        reject_job_changes_for_bsp: %{
  #          title: "",
  #          description: "!!REJECTED!!- {{service_type}} Appointment  # {{job_id}} changes have been rejected and the good news is your original appointment intact."
  #        }
  #      },
  #      %{
  #        cancel_job_for_cmr: %{
  #          title: "",
  #          description: "!!CANCELLED - Your Action Required!! {{service_type}} Appointment  # {{job_id}} has been CANCELLED, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        cancel_job_for_bsp: %{
  #          title: "",
  #          description: "!!CANCELLED - Your Action Required!! {{service_type}} Appointment  # {{job_id}} has been CANCELLED, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        reschedule_job_for_bsp: %{
  #          title: "",
  #          description: "!!RESCHEDULE - Your action REQUIRED!! {{service_type}} Appointment  # {{job_id}} has been Re-scheduled
  #           with Business Service Provider {{bsp_branch_profile_name}}, please verify and Accept OR Reject the changes."
  #        }
  #      },
  #      %{
  #        reschedule_job_for_cmr: %{
  #          title: "",
  #          description: "!!RESCHEDULE - Your action REQUIRED!! {{service_type}} Appointment  # {{job_id}} has been Re-scheduled
  #           with Business Service Provider {{bsp_branch_profile_name}}, please verify and Accept OR Reject the changes."
  #        }
  #      },
  #      %{
  #        agent_reassign_job_for_cmr: %{
  #          title: "",
  #          description: "!!CHANGES - No Action needed!! FYI. Agent assignment for {{service_type}} Appointment  # {{job_id}} has been updated."
  #        }
  #      },
  #      %{
  #        agent_reassign_job_for_bsp_emp: %{
  #          title: "",
  #          description: "!!CHANGES - Action REQUIRED!! {{service_type}} Appointment  # {{job_id}} has been assigned
  #           to Emp# {{current_employee_id}} from Emp# {{previous_employee_id}}. Please note and verify and plan."
  #        }
  #      },
  #      %{
  #        invoice_ready_for_cmr: %{
  #          title: "",
  #          description: "!!INVOICED BILLED - Your action REQUIRED!! - Your {{service_type}} Appointment  # {{job_id}}
  #            has been completed and ready for PAYMENT of  {{invoice_amount}} and appreciate your quick payment."
  #        }
  #      },
  #      %{
  #        adjust_invoice_for_bsp: %{
  #          title: "",
  #          description: "!!ADJUST INVOICE - Your action REQUIRED!! - Consumer requested an adjustment in Invoice# {{invoice_id}}. Act fast to get paid."
  #        }
  #      },
  #      %{
  #        adjusted_invoice_for_cmr: %{
  #          title: "",
  #          description: "!!INVOICE ADJUSTED - Your action REQUIRED!! - Your {{service_type}} Appointment# {{job_id}} has been completed and
  #            ready for PAYMENT of  {{invoice_amount}} and appreciate your quick payment."
  #        }
  #      },
  #      %{
  #        raise_dispute_for_bsp: %{
  #          title: "",
  #          description: "!!DISPUTE RAISED - Your action REQUIRED!! - Consumer requested to resolve issue with {{service_type}} Appointment  #
  #            {{job_id}} and  invoice amount:  {{invoice_amount}}. Act fast to resolve the dispute."
  #        }
  #      },
  #      %{
  #        manage_dispute_for_cmr: %{
  #          title: "",
  #          description: "!!DISPUTE RESOLVED - Your action REQUIRED!! - Dispute on {{service_type}} Appointment  # {{job_id}}
  #           has been resolved and revised invoice amount:  {{invoice_amount}} ready for payment, appreciate your prompt payment."
  #        }
  #      },
  #      %{
  #        on_board_walk_in_cmr_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        bsp_on_boards_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        walk_in_cmr_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        in_home_on_demand_bsp_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Business Provider for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{employee_id}}"
  #        }
  #      },
  #      %{
  #        in_home_on_demand_bsp_near_appointment_cmr_bsp_initiates_on_board_action: %{
  #          title: "",
  #          description: "!INFORMATION!! Business Provider for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{employee_id}}"
  #        }
  #      },
  #      %{
  #        appointment_alert_12_hrs_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 12 hours."
  #        }
  #      },
  #      %{
  #        appointment_alert_2_hrs_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 2 hours."
  #        }
  #      },
  #      %{
  #        appointment_alert_30_mins_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 30 minutes."
  #        }
  #      },
  #      %{
  #        appointment_alert_5_mins_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 5 minutes."
  #        }
  #      },
  #      %{
  #        payment_made: %{
  #          title: "",
  #          description: "!!PAYMENT PROCESSED!! - Your payment  {{invoice_amount}} for {{service_type}} Appointment  #
  #            {{job_id}} has been processed successfully, thank you and looking forward to doing business with you again."
  #        }
  #      },
  #      %{
  #        bsp_sends_employment_invitation_to_cmr: %{
  #          title: "Employee Enrollment",
  #          description: "!!NEW EMPLOYMENT, ACTION NEEDED!! Welcome onboard for your employment offer from {{bsp_profile_name}}. Click here for next steps."
  #        }
  #      },
  #      %{
  #        reset_password_for_cmr: %{
  #          title: "Reset Password",
  #          description: "!!ACCOUNT UPDATE - Your action REQUIRED!! An email sent with update Instructions."
  #        }
  #      },
  #      %{
  #        update_platform_terms: %{
  #          title: "Platform Terms Updated",
  #          description: "Platform Terms Updated"
  #        }
  #      }
  #    ],
  #    hi: [
  #      %{
  #        create_job_pending_for_cmr: %{
  #          title: "",
  #          description: "!!THANK YOU!! - Your {{service_type}} Appointment # {{job_id}} has been created and waiting for service provider {{bsp_profile_name}} approval."
  #        }
  #      },
  #      %{
  #        create_job_pending_for_bsp: %{
  #          title: "",
  #          description: "!!ACTION REQUIRED!! Congratulations you are scheduled for a new {{service_type}} Appointment # {{job_id}} assigned to {{emp_profile_name}} with {{cmr_profile_name}}"
  #        }
  #      },
  #      %{
  #        create_job_confirmed_for_cmr: %{
  #          title: "",
  #          description: "!!THANK YOU!!- Your {{service_type}} Appointment  # {{job_id}} has been created, scheduled and assigned to service provider {{bsp_profile_name}}."
  #        }
  #      },
  #      %{
  #        create_job_confirmed_for_bsp: %{
  #          title: "",
  #          description: "!!NEW APPOINTMENT!!- Congratulations you are scheduled for a new {{service_type}} Appointment  # {{job_id}} assigned to {{emp_profile_name}} with {{cmr_profile_name}}."
  #        }
  #      },
  #      %{
  #        accept_job_for_cmr: %{
  #          title: "",
  #          description: "!!ACCEPTED!!- Your {{service_type}} Appointment  # {{job_id}} changes accepted, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        accept_job_changes_for_bsp: %{
  #          title: "",
  #          description: "!!ACCEPTED!!- Your {{service_type}} Appointment  # {{job_id}} changes accepted, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        reject_job_for_cmr: %{
  #          title: "",
  #          description: "!!REJECTED!!- {{service_type}} Appointment  # {{job_id}} changes have been rejected and the good news is your original appointment intact."
  #        }
  #      },
  #      %{
  #        reject_job_changes_for_bsp: %{
  #          title: "",
  #          description: "!!REJECTED!!- {{service_type}} Appointment  # {{job_id}} changes have been rejected and the good news is your original appointment intact."
  #        }
  #      },
  #      %{
  #        cancel_job_for_cmr: %{
  #          title: "",
  #          description: "!!CANCELLED - Your Action Required!! {{service_type}} Appointment  # {{job_id}} has been CANCELLED, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        cancel_job_for_bsp: %{
  #          title: "",
  #          description: "!!CANCELLED - Your Action Required!! {{service_type}} Appointment  # {{job_id}} has been CANCELLED, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        reschedule_job_for_bsp: %{
  #          title: "",
  #          description: "!!RESCHEDULE - Your action REQUIRED!! {{service_type}} Appointment  # {{job_id}}
  #            has been Re-scheduled with Business Service Provider {{bsp_branch_profile_name}}, please verify and Accept OR Reject the changes."
  #        }
  #      },
  #      %{
  #        reschedule_job_for_cmr: %{
  #          title: "",
  #          description: "!!RESCHEDULE - Your action REQUIRED!! {{service_type}} Appointment  # {{job_id}} has been
  #            Re-scheduled with Business Service Provider {{bsp_branch_profile_name}}, please verify and Accept OR Reject the changes."
  #        }
  #      },
  #      %{
  #        agent_reassign_job_for_cmr: %{
  #          title: "",
  #          description: "!!CHANGES - No Action needed!! FYI. Agent assignment for {{service_type}} Appointment  # {{job_id}} has been updated."
  #        }
  #      },
  #      %{
  #        agent_reassign_job_for_bsp_emp: %{
  #          title: "",
  #          description: "!!CHANGES - Action REQUIRED!! {{service_type}} Appointment  # {{job_id}}
  #            has been assigned to Emp# {{current_employee_id}} from Emp# {{previous_employee_id}}. Please note and verify and plan."
  #        }
  #      },
  #      %{
  #        invoice_ready_for_cmr: %{
  #          title: "",
  #          description: "!!INVOICED BILLED - Your action REQUIRED!! - Your {{service_type}} Appointment  # {{job_id}}
  #            has been completed and ready for PAYMENT of  {{invoice_amount}} and appreciate your quick payment."
  #        }
  #      },
  #      %{
  #        adjust_invoice_for_bsp: %{
  #          title: "",
  #          description: "!!ADJUST INVOICE - Your action REQUIRED!! - Consumer requested an adjustment in Invoice# {{invoice_id}}. Act fast to get paid."
  #        }
  #      },
  #      %{
  #        adjusted_invoice_for_cmr: %{
  #          title: "",
  #          description: "!!INVOICE ADJUSTED - Your action REQUIRED!! - Your {{service_type}} Appointment# {{job_id}} has been
  #            completed and ready for PAYMENT of  {{invoice_amount}} and appreciate your quick payment."
  #        }
  #      },
  #      %{
  #        raise_dispute_for_bsp: %{
  #          title: "",
  #          description: "!!DISPUTE RAISED - Your action REQUIRED!! - Consumer requested to resolve issue with {{service_type}} Appointment  # {{job_id}}
  #            and  invoice amount:  {{invoice_amount}}. Act fast to resolve the dispute."
  #        }
  #      },
  #      %{
  #        manage_dispute_for_cmr: %{
  #          title: "",
  #          description: "!!DISPUTE RESOLVED - Your action REQUIRED!! - Dispute on {{service_type}} Appointment  # {{job_id}} has
  #             been resolved and revised invoice amount:  {{invoice_amount}} ready for payment, appreciate your prompt payment."
  #        }
  #      },
  #      %{
  #        on_board_walk_in_cmr_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        bsp_on_boards_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        walk_in_cmr_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        in_home_on_demand_bsp_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Business Provider for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{employee_id}}"
  #        }
  #      },
  #      %{
  #        in_home_on_demand_bsp_near_appointment_cmr_bsp_initiates_on_board_action: %{
  #          title: "",
  #          description: "!INFORMATION!! Business Provider for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{employee_id}}"
  #        }
  #      },
  #      %{
  #        appointment_alert_12_hrs_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 12 hours."
  #        }
  #      },
  #      %{
  #        appointment_alert_2_hrs_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 2 hours."
  #        }
  #      },
  #      %{
  #        appointment_alert_30_mins_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 30 minutes."
  #        }
  #      },
  #      %{
  #        appointment_alert_5_mins_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 5 minutes."
  #        }
  #      },
  #      %{
  #        payment_made: %{
  #          title: "",
  #          description: "!!PAYMENT PROCESSED!! - Your payment  {{invoice_amount}} for {{service_type}} Appointment  # {{job_id}}
  #            has been processed successfully, thank you and looking forward to doing business with you again."
  #        }
  #      },
  #      %{
  #        bsp_sends_employment_invitation_to_cmr: %{
  #          title: "Employee Enrollment",
  #          description: "!!NEW EMPLOYMENT, ACTION NEEDED!! Welcome onboard for your employment offer from {{bsp_profile_name}}. Click here for next steps."
  #        }
  #      },
  #      %{
  #        reset_password_for_cmr: %{
  #          title: "Reset Password",
  #          description: "!!ACCOUNT UPDATE - Your action REQUIRED!! An email sent with update Instructions."
  #        }
  #      },
  #      %{
  #        update_platform_terms: %{
  #          title: "Platform Terms Updated",
  #          description: "Platform Terms Updated"
  #        }
  #      }
  #    ],
  #    ur: [
  #      %{
  #        create_job_pending_for_cmr: %{
  #          title: "",
  #          description: "!!THANK YOU!! - Your {{service_type}} Appointment # {{job_id}} has been created and waiting for service provider {{bsp_profile_name}} approval."
  #        }
  #      },
  #      %{
  #        create_job_pending_for_bsp: %{
  #          title: "",
  #          description: "!!ACTION REQUIRED!! Congratulations you are scheduled for a new {{service_type}}
  #           Appointment # {{job_id}} assigned to {{emp_profile_name}} with {{cmr_profile_name}}"
  #        }
  #      },
  #      %{
  #        create_job_confirmed_for_cmr: %{
  #          title: "",
  #          description: "!!THANK YOU!!- Your {{service_type}} Appointment  # {{job_id}} has been created, scheduled and assigned to service provider {{bsp_profile_name}}."
  #        }
  #      },
  #      %{
  #        create_job_confirmed_for_bsp: %{
  #          title: "",
  #          description: "!!NEW APPOINTMENT!!- Congratulations you are scheduled for a new {{service_type}} Appointment  # {{job_id}} assigned to {{emp_profile_name}} with {{cmr_profile_name}}."
  #        }
  #      },
  #      %{
  #        accept_job_for_cmr: %{
  #          title: "",
  #          description: "!!ACCEPTED!!- Your {{service_type}} Appointment  # {{job_id}} changes accepted, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        accept_job_changes_for_bsp: %{
  #          title: "",
  #          description: "!!ACCEPTED!!- Your {{service_type}} Appointment  # {{job_id}} changes accepted, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        reject_job_for_cmr: %{
  #          title: "",
  #          description: "!!REJECTED!!- {{service_type}} Appointment  # {{job_id}} changes have been rejected and the good news is your original appointment intact."
  #        }
  #      },
  #      %{
  #        reject_job_changes_for_bsp: %{
  #          title: "",
  #          description: "!!REJECTED!!- {{service_type}} Appointment  # {{job_id}} changes have been rejected and the good news is your original appointment intact."
  #        }
  #      },
  #      %{
  #        cancel_job_for_cmr: %{
  #          title: "",
  #          description: "!!CANCELLED - Your Action Required!! {{service_type}} Appointment  # {{job_id}} has been CANCELLED, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        cancel_job_for_bsp: %{
  #          title: "",
  #          description: "!!CANCELLED - Your Action Required!! {{service_type}} Appointment  # {{job_id}} has been CANCELLED, please verify and acknowledge the changes."
  #        }
  #      },
  #      %{
  #        reschedule_job_for_bsp: %{
  #          title: "",
  #          description: "!!RESCHEDULE - Your action REQUIRED!! {{service_type}} Appointment  # {{job_id}} has been Re-scheduled with
  #            Business Service Provider {{bsp_branch_profile_name}}, please verify and Accept OR Reject the changes."
  #        }
  #      },
  #      %{
  #        reschedule_job_for_cmr: %{
  #          title: "",
  #          description: "!!RESCHEDULE - Your action REQUIRED!! {{service_type}} Appointment  # {{job_id}} has been Re-scheduled
  #            with Business Service Provider {{bsp_branch_profile_name}}, please verify and Accept OR Reject the changes."
  #        }
  #      },
  #      %{
  #        agent_reassign_job_for_cmr: %{
  #          title: "",
  #          description: "!!CHANGES - No Action needed!! FYI. Agent assignment for {{service_type}} Appointment  # {{job_id}} has been updated."
  #        }
  #      },
  #      %{
  #        agent_reassign_job_for_bsp_emp: %{
  #          title: "",
  #          description: "!!CHANGES - Action REQUIRED!! {{service_type}} Appointment  # {{job_id}} has been assigned to
  #            Emp# {{current_employee_id}} from Emp# {{previous_employee_id}}. Please note and verify and plan."
  #        }
  #      },
  #      %{
  #        invoice_ready_for_cmr: %{
  #          title: "",
  #          description: "!!INVOICED BILLED - Your action REQUIRED!! - Your {{service_type}} Appointment  # {{job_id}} has
  #            been completed and ready for PAYMENT of  {{invoice_amount}} and appreciate your quick payment."
  #        }
  #      },
  #      %{
  #        adjust_invoice_for_bsp: %{
  #          title: "",
  #          description: "!!ADJUST INVOICE - Your action REQUIRED!! - Consumer requested an adjustment in Invoice# {{invoice_id}}. Act fast to get paid."
  #        }
  #      },
  #      %{
  #        adjusted_invoice_for_cmr: %{
  #          title: "",
  #          description: "!!INVOICE ADJUSTED - Your action REQUIRED!! - Your {{service_type}} Appointment# {{job_id}} has been completed and
  #            ready for PAYMENT of  {{invoice_amount}} and appreciate your quick payment."
  #        }
  #      },
  #      %{
  #        raise_dispute_for_bsp: %{
  #          title: "",
  #          description: "!!DISPUTE RAISED - Your action REQUIRED!! - Consumer requested to resolve issue with {{service_type}}
  #            Appointment  # {{job_id}} and  invoice amount:  {{invoice_amount}}. Act fast to resolve the dispute."
  #        }
  #      },
  #      %{
  #        manage_dispute_for_cmr: %{
  #          title: "",
  #          description: "!!DISPUTE RESOLVED - Your action REQUIRED!! - Dispute on {{service_type}} Appointment  # {{job_id}}
  #            has been resolved and revised invoice amount:  {{invoice_amount}} ready for payment, appreciate your prompt payment."
  #        }
  #      },
  #      %{
  #        on_board_walk_in_cmr_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        bsp_on_boards_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        walk_in_cmr_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Consumer for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{ticket_number}}"
  #        }
  #      },
  #      %{
  #        in_home_on_demand_bsp_near_appointment: %{
  #          title: "",
  #          description: "!INFORMATION!! Business Provider for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{employee_id}}"
  #        }
  #      },
  #      %{
  #        in_home_on_demand_bsp_near_appointment_cmr_bsp_initiates_on_board_action: %{
  #          title: "",
  #          description: "!INFORMATION!! Business Provider for {{service_type}} Appointment  # {{job_id}} is near by and Onboarded successfully with Token#  {{employee_id}}"
  #        }
  #      },
  #      %{
  #        appointment_alert_12_hrs_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 12 hours."
  #        }
  #      },
  #      %{
  #        appointment_alert_2_hrs_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 2 hours."
  #        }
  #      },
  #      %{
  #        appointment_alert_30_mins_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 30 minutes."
  #        }
  #      },
  #      %{
  #        appointment_alert_5_mins_earlier: %{
  #          title: "",
  #          description: "!!ALERT!! Your schedule {{service_type}} Appointment  # {{job_id}} is about to begin in 5 minutes."
  #        }
  #      },
  #      %{
  #        payment_made: %{
  #          title: "",
  #          description: "!!PAYMENT PROCESSED!! - Your payment  {{invoice_amount}} for {{service_type}} Appointment  # {{job_id}}
  #            has been processed successfully, thank you and looking forward to doing business with you again."
  #        }
  #      },
  #      %{
  #        bsp_sends_employment_invitation_to_cmr: %{
  #          title: "Employee Enrollment",
  #          description: "!!NEW EMPLOYMENT, ACTION NEEDED!! Welcome onboard for your employment offer from {{bsp_profile_name}}. Click here for next steps."
  #        }
  #      },
  #      %{
  #        reset_password_for_cmr: %{
  #          title: "Reset Password",
  #          description: "!!ACCOUNT UPDATE - Your action REQUIRED!! An email sent with update Instructions."
  #        }
  #      },
  #      %{
  #        update_platform_terms: %{
  #          title: "Platform Terms Updated",
  #          description: "Platform Terms Updated"
  #        }
  #      }
  #    ]
  #  }

  #  def push_notification_message(lang, key, params \\ %{}) do
  #    default_msg = %{
  #      type: nil,
  #      description: nil,
  #      title: nil,
  #      image: "default",
  #      sound: "default",
  #      id: nil,
  #      badge: nil,
  #      user_id: nil,
  #      time: nil
  #    }
  #    key = String.to_atom(key)
  #    case Enum.filter(@push_notification_messages[String.to_atom(lang)], & &1[key]) do
  #      [] -> {:error, ["no message exists for this notification!"]}
  #      [notification_message] ->
  #        param_keys = Map.keys(params)
  #        message_body = notification_message[key].description
  #
  ##    our pattern strings in message body (e.g job_id) and keys of params sending as last argument from enqeue (job_id)should be same
  #        message_body = Enum.reduce(param_keys, message_body, fn param_key, body ->
  #          String.replace(body, to_string(param_key), to_string(params[param_key]))
  #        end)
  #        {_, final_message} = get_and_update_in(notification_message[key][:description], &{&1, message_body})
  #        {:ok, Map.merge(default_msg, final_message[key])}
  #      all -> {:error, all}
  #    end
  #  rescue
  #    exception ->
  #      logger(__MODULE__, exception, @common_error, __ENV__.line)
  #  end

  def push_notification_message("send_in_blue", lang, key, params \\ %{}) do
    default_msg = %{
      type: nil,
      description: nil,
      title: nil,
      image: "default",
      sound: "default",
      click_action: nil,
      payment_id: nil,
      id: nil,
      screen: nil,
      extra_data: nil,
      badge: nil,
      user_id: nil,
      time: nil,
      call_initiator_detail: nil
    }

    cond do
      Map.has_key?(params, "job_id") ->
        %{id: branch_id} = Core.BSP.get_branch_by_job_id(params["job_id"])
        get_user_selected_sendinblue_template(default_msg, key, branch_id, lang, params)

      Map.has_key?(params, "branch_id") ->
        get_user_selected_sendinblue_template(default_msg, key, params["branch_id"], lang, params)

      true ->
        default_template(default_msg, key, lang, params)
    end
  end

  def get_user_selected_sendinblue_template(default_msg, key, branch_id, lang, params) do
    case Core.Emails.get_template_id_by(key, branch_id) do
      %{send_in_blue_notification_template_id: template_id} when template_id |> is_integer() ->
        %{subject: notification_body} =
          Emails.getting_sendinblue_email_template(template_id, lang, params)

        merge_data(key, notification_body, default_msg, params)

      _ ->
        default_template(default_msg, key, lang, params)
    end
  end

  # TODO: Get these default template from the table(email_templates).
  def default_template(default_msg, key, lang, params) do
    %{subject: notification_body} =
      case key do
        "create_job_confirmed_for_cmr" ->
          Emails.getting_sendinblue_email_template(22, lang, params, true)

        "create_job_confirmed_for_bsp" ->
          Emails.getting_sendinblue_email_template(23, lang, params, true)

        "create_job_pending_for_cmr" ->
          Emails.getting_sendinblue_email_template(24, lang, params, true)

        "create_job_pending_for_bsp" ->
          Emails.getting_sendinblue_email_template(25, lang, params, true)

        "accept_job_for_cmr" ->
          Emails.getting_sendinblue_email_template(26, lang, params, true)

        "accept_job_changes_for_bsp" ->
          Emails.getting_sendinblue_email_template(27, lang, params, true)

        "reject_job_for_cmr" ->
          Emails.getting_sendinblue_email_template(28, lang, params, true)

        "reject_job_changes_for_bsp" ->
          Emails.getting_sendinblue_email_template(29, lang, params, true)

        "cancel_job_for_cmr" ->
          Emails.getting_sendinblue_email_template(30, lang, params, true)

        "cancel_job_for_bsp" ->
          Emails.getting_sendinblue_email_template(31, lang, params, true)

        "reschedule_job_for_bsp" ->
          Emails.getting_sendinblue_email_template(32, lang, params, true)

        "reschedule_job_for_cmr" ->
          Emails.getting_sendinblue_email_template(33, lang, params, true)

        "agent_reassign_job_for_cmr" ->
          Emails.getting_sendinblue_email_template(34, lang, params, true)

        "reassign_job_for_bsp_emp" ->
          Emails.getting_sendinblue_email_template(35, lang, params, true)

        "invoice_ready_for_cmr" ->
          Emails.getting_sendinblue_email_template(36, lang, params, true)

        "adjust_invoice_for_bsp" ->
          Emails.getting_sendinblue_email_template(37, lang, params, true)

        "adjusted_invoice_for_cmr" ->
          Emails.getting_sendinblue_email_template(38, lang, params, true)

        "raise_dispute_for_bsp" ->
          Emails.getting_sendinblue_email_template(39, lang, params, true)

        "manage_dispute_for_cmr" ->
          Emails.getting_sendinblue_email_template(40, lang, params, true)

        "on_board_walk_in_cmr_near_appointment" ->
          Emails.getting_sendinblue_email_template(41, lang, params, true)

        "bsp_on_boards_appointment" ->
          Emails.getting_sendinblue_email_template(42, lang, params, true)

        "walk_in_cmr_near_appointment" ->
          Emails.getting_sendinblue_email_template(43, lang, params, true)

        "in_home_on_demand_bsp_near_appointment" ->
          Emails.getting_sendinblue_email_template(44, lang, params, true)

        "in_home_on_demand_bsp_near_appointment_cmr_bsp_initiates_on_board_action" ->
          Emails.getting_sendinblue_email_template(45, lang, params, true)

        "appointment_alert_12_hrs_earlier" ->
          Emails.getting_sendinblue_email_template(46, lang, params, true)

        "appointment_alert_2_hrs_earlier" ->
          Emails.getting_sendinblue_email_template(47, lang, params, true)

        "appointment_alert_30_mins_earlier" ->
          Emails.getting_sendinblue_email_template(48, lang, params, true)

        "appointment_alert_5_mins_earlier" ->
          Emails.getting_sendinblue_email_template(49, lang, params, true)

        "payment_made" ->
          Emails.getting_sendinblue_email_template(50, lang, params, true)

        "bsp_sends_employment_invitation_to_cmr" ->
          Emails.getting_sendinblue_email_template(51, lang, params, true)

        "reset_password_for_cmr" ->
          Emails.getting_sendinblue_email_template(52, lang, params, true)

        "update_platform_terms" ->
          Emails.getting_sendinblue_email_template(53, lang, params, true)

        "cmr_accepts_employment_invitation_to_bsp" ->
          Emails.getting_sendinblue_email_template(55, lang, params, true)

        "cash_payment_for_bsp" ->
          Emails.getting_sendinblue_email_template(56, lang, params, true)

        "cash_payment_for_cmr" ->
          Emails.getting_sendinblue_email_template(54, lang, params, true)

        "cheque_payment_for_bsp" ->
          Emails.getting_sendinblue_email_template(57, lang, params, true)

        "cheque_payment_for_cmr" ->
          Emails.getting_sendinblue_email_template(58, lang, params, true)

        "new_bid_request_to_bsp" ->
          Emails.getting_sendinblue_email_template(66, lang, params, true)

        "bid_reject_to_bsp" ->
          Emails.getting_sendinblue_email_template(59, lang, params, true)

        "job_request_to_bsp_on_demand" ->
          Emails.getting_sendinblue_email_template(77, lang, params, true)

        "call" ->
          %{subject: "Incoming call.."}

        _ ->
          Emails.getting_sendinblue_email_template(53, lang, params, true)
      end

    merge_data(key, notification_body, default_msg, params)
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  def merge_data(key, notification_body, default_msg, params) do
    case key do
      "cash_payment_for_bsp" ->
        {:ok,
         Map.merge(default_msg, %{
           title: "",
           description: notification_body,
           payment_id: params["payment_id"],
           click_action: "CASH_CONFIRM_BSP",
           screen: "/transactionDetailsPage",
           extra_data: ""
         })}

      "cheque_payment_for_bsp" ->
        {:ok,
         Map.merge(default_msg, %{
           title: "",
           description: notification_body,
           payment_id: params["payment_id"],
           click_action: "CHEQUE_CONFIRM_BSP",
           screen: "/transactionDetailsPage",
           extra_data: ""
         })}

      "call" ->
        {:ok,
         Map.merge(
           default_msg,
           %{
             title: "",
             description: notification_body,
             click_action: "accept_or_reject",
             call_initiator_detail: params[:call_initiator_detail]
           }
         )}

      _ ->
        {:ok, Map.merge(default_msg, %{title: "", description: notification_body})}
    end
  end

  #  def send_notification(app, device_token, lang, key, params \\ %{}) do
  #    case push_notification_message(lang, key, params) do
  #      {:ok, notification} -> device_verification(app, device_token, key, notification)
  #      {:error, error} -> {:error, error}
  #      _ -> {:error, ["something went wrong while making notification"]}
  #    end
  #  end

  #  def device_verification(app, device_token, key, notification) do
  #    cond do
  #      String.contains?(app, "android") ->
  #        notification = Pigeon.FCM.Notification.new(device_token, notification[String.to_atom(key)])
  ##        Pigeon.FCM.push(notification, key: Application.get_env(:pigeon, :fcm)[:fcm_default][:key])
  #        %Pigeon.FCM.Notification{message_id: _msg_id, response: response, status: _status} = notification =
  #          Pigeon.FCM.push(notification, key: Application.get_env(:pigeon, :fcm)[Mix.env][:key])
  #        {:ok, notification}
  #      String.contains?(app, "ios") ->
  #        notification = Pigeon.APNS.Notification.new(notification[String.to_atom(key)], device_token)
  #                       |> Pigeon.APNS.push(key: Application.get_env(:pigeon, :apns)[:apns_default])
  #        {:ok, notification}
  #      true -> {:error, ["invalid operating system!"]}
  #    end
  #  end

  #  @moduledoc """
  #
  #  """
  #  defstruct name: "John", age: 27
  #
  #  @general_messages %{
  #    integer: %{
  #      type: :integer,
  #      format: :int32,
  #      example: 1
  #    }
  #  }
  #  def general_message(key) do
  #    @general_messages[key]
  #  end
  #
  # You need to update id later like this %{msg | id: 2}
  #  @push_notification_messages %{
  #    en: %{
  #      provider_approved: %CoreWeb.Utils.Notification{
  #        type: "provider_approved",
  #        description:
  #          "Congratulations, your Qserv account has been activated, you may now receive jobs",
  #        title: "Account Activated"
  #      }
  #    }
  #  }
  #  def push_notification_message(lang, key) do
  #    @push_notification_messages[String.to_atom(lang)][key]
  #  end
end
