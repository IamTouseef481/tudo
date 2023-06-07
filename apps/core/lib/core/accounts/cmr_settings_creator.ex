defmodule Core.Accounts.CMRSettingsCreator do
  @moduledoc false

  import CoreWeb.Utils.Errors
  alias Core.Settings

  def create_cmr_settings(user_id) do
    cmr_settings = [
      %{
        title: "Dashboard auto refresh",
        slug: "dashboard_auto_refresh",
        type: "preference",
        user_id: user_id,
        fields: [
          %{
            dashboard_auto_refresh: true
          }
        ]
      },
      %{
        title: "Share your location",
        slug: "share_location_with_user",
        type: "preference",
        user_id: user_id,
        fields: [
          %{
            share_location_with_user: true
          }
        ]
      },
      %{
        title: "Profile visibility",
        slug: "profile_visibility",
        type: "preference",
        user_id: user_id,
        fields: [
          %{
            profile_visibility: true
          }
        ]
      },
      %{
        title: "Send notifications",
        slug: "send_notifications",
        type: "preference",
        user_id: user_id,
        fields: [
          %{
            send_notifications: true
          }
        ]
      },
      %{
        title: "Send emails",
        slug: "send_emails",
        type: "preference",
        user_id: user_id,
        fields: [
          %{
            send_emails: true
          }
        ]
      },
      %{
        title: "Sync Google Calender",
        slug: "sync_google_calender",
        type: "preference",
        user_id: user_id,
        fields: [
          %{
            sync_google_calender: true
          }
        ]
      }
    ]

    Enum.reduce(cmr_settings, [], fn setting, acc ->
      case Settings.create_cmr_settings(setting) do
        {:ok, setting} -> [setting | acc]
        {:error, _} -> acc
        _ -> acc
      end
    end)
  rescue
    exception ->
      logger(__MODULE__, exception, ["error in create user settings"], __ENV__.line)
  end

  #  def create_email_settings({:user_id, user_id}) do
  def create_email_settings(user_id) do
    email_settings = [
      %{
        user_id: user_id,
        category_id: "job",
        slug: "create_job_confirmed_for_cmr",
        title: "Create Job Confirmed",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "job",
        slug: "create_job_pending_for_cmr",
        title: "Create Job Pending",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "job",
        slug: "cancel_job_for_cmr",
        title: "Cancel Job",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "job",
        slug: "reschedule_job_for_cmr",
        title: "Reschedule Job",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "payment",
        slug: "invoice_ready_for_cmr",
        title: "Job Invoice",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "payment",
        slug: "adjusted_invoice_for_cmr",
        title: "Adjusted Invoice",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "payment",
        slug: "manage_dispute_for_cmr",
        title: "Manage Dispute",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "tudo_account",
        slug: "update_platform_terms",
        title: "Update Platform Terms",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "payment",
        slug: "payment_made",
        title: "Payment Made",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "job",
        slug: "reject_job_changes_for_bsp",
        title: "Reject Changes",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "job",
        slug: "accept_job_changes_for_bsp",
        title: "Accept Job Changes",
        is_active: true
      },
      %{
        user_id: user_id,
        category_id: "invitation",
        slug: "invite_employee",
        title: "Invite Employee",
        is_active: true
      },
      #      %{
      #        user_id: user_id,
      #        category_id: "tudo_account",
      #        slug: "forget_password",
      #        is_active: true
      #      },
      %{
        user_id: user_id,
        category_id: "tudo_account",
        slug: "invite_cmr",
        title: "Invite CMR",
        is_active: true
      }
    ]

    Enum.reduce(email_settings, [], fn setting, acc ->
      case Core.Emails.create_email_setting(setting) do
        {:ok, setting} -> [setting | acc]
        {:error, _} -> acc
        _ -> acc
      end
    end)
  rescue
    exception ->
      logger(__MODULE__, exception, ["error in creating cmr email settings"], __ENV__.line)
  end

  #  not needed BSP email settings for now
  #  def create_bsp_email_settings(user_id) do
  #    email_settings = [
  #      %{
  #        user_id: user_id,
  #        category_id: "job",
  #        slug: "create_job_confirmed_for_bsp",
  #        is_active: true
  #      },
  #      %{
  #        user_id: user_id,
  #        category_id: "job",
  #        slug: "cancel_job_for_bsp",
  #        is_active: true
  #      },
  #      %{
  #        user_id: user_id,
  #        category_id: "job",
  #        slug: "create_job_pending_for_bsp",
  #        is_active: true
  #      },
  #      %{
  #        user_id: user_id,
  #        category_id: "payment",
  #        slug: "adjust_invoice_for_bsp",
  #        is_active: true
  #      },
  #      %{
  #        user_id: user_id,
  #        category_id: "payment",
  #        slug: "raise_dispute_for_bsp",
  #        is_active: true
  #      },
  #      %{
  #        user_id: user_id,
  #        category_id: "job",
  #        slug: "reschedule_job_for_bsp",
  #        is_active: true
  #      }
  #    ]
  #    Enum.reduce(email_settings, [], fn setting, acc ->
  #      case Core.Emails.create_email_setting(setting) do
  #        {:ok, setting} -> [setting | acc]
  #        {:error, _} -> acc
  #        _ -> acc
  #      end
  #    end)
  #  rescue
  #    all ->
  #      {:error, ["error in creating bsp email settings"]}
  #  end
end
