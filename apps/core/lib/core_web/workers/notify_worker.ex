defmodule CoreWeb.Workers.NotifyWorker do
  @moduledoc false

  import CoreWeb.Utils.Errors

  alias Core.{Accounts, Employees, MetaData, Notifications}
  alias CoreWeb.Helpers.AdminNotificationSettingsHelper, as: ADS

  require Logger

  def perform(msg_id, user_id, lan, user_role, params \\ %{}, silent_push \\ false) do
    if ADS.check_admin_notification_permission(user_role, msg_id) do
      user_installs = Accounts.get_user_installs_by_user(user_id)

      notify_data =
        Enum.reduce(user_installs, nil, fn
          %{fcm_token: fcm_token}, acc when is_nil(fcm_token) or fcm_token == "" ->
            acc

          %{os: device, fcm_token: fcm_token}, acc ->
            case send_notification_for_single_device(
                   msg_id,
                   user_id,
                   user_role,
                   lan,
                   device,
                   fcm_token,
                   params,
                   silent_push
                 ) do
              {:ok, data} -> data
              _ -> acc
            end
        end)

      with %{notification_map: notification, role: role} <- notify_data,
           {:ok, notification} <- create_local_push_notification(notification, role),
           {:ok, _} <- update_cmr_meta(notification, 1),
           {:ok, _} <- update_bsp_meta(notification, 1) do
        {:ok, notification}
      else
        _ -> {:ok, ["notification not sent"]}
      end
    else
      {:ok, ["Admin didn't allowed notification on this event for this role"]}
    end
  rescue
    exception ->
      Logger.info("""
        #{inspect(exception, pretty: true)}
      """)

      {:ok, ["error in worker"]}
  end

  def send_notification_for_single_device(
        msg_id,
        user_id,
        role,
        lan,
        device,
        fcm_token,
        params,
        silent_push
      ) do
    # msg_id is key to find msg
    #    with {:ok, msg} <- CoreWeb.Utils.Messages.push_notification_message(lan, msg_id, params) do
    case CoreWeb.Utils.Messages.push_notification_message("send_in_blue", lan, msg_id, params) do
      {:ok, msg} ->
        identity_url = Application.get_env(:core, :identify_host_url)

        notification_data =
          cond do
            identity_url == "localhost" ->
              Map.merge(msg, %{
                description: "Test Server:" <> msg.description,
                id: user_id,
                user_id: user_id
              })

            true ->
              Map.merge(msg, %{id: user_id, user_id: user_id})
          end

        notification = Map.merge(notification_data, %{branch_id: params["branch_id"]})

        cond do
          device == nil ->
            false

          String.contains?(device, ["ios", "Ios", "IOS"]) ->
            package_name = Application.get_env(:core, :package)[Mix.env()]

            n =
              if silent_push do
                CoreWeb.Utils.Notification.apns_silent(notification_data, fcm_token, package_name)
              else
                CoreWeb.Utils.Notification.apns(notification_data, fcm_token, package_name)
              end

            sending_notification(fcm_token, n, notification, role)

          String.contains?(device, ["android", "Android", "ANDROID"]) ->
            n =
              if silent_push do
                CoreWeb.Utils.Notification.fcm_data_msg(notification_data, fcm_token)
              else
                CoreWeb.Utils.Notification.fcm(notification_data, fcm_token)
              end

            sending_notification(fcm_token, n, notification, role)

          true ->
            {:error, ["Device not correct or not supported"]}
        end

      {:error, error} ->
        logger(__MODULE__, error, error, __ENV__.line)

      _ ->
        {:error, ["unable to fetch notification data"]}
    end
  rescue
    exception ->
      Logger.info("""
        #{inspect(exception, pretty: true)}
      """)

      {:ok, ["error in send_notification_for_single_device fun"]}
  end

  defp sending_notification(_fcm_token, body, notification_map, role) do
    fcm_key = "key=" <> Application.get_env(:pigeon, :fcm)[Mix.env()][:key]
    url = "https://fcm.googleapis.com/fcm/send"

    {:ok, %{body: body, status_code: status_code}} =
      HTTPoison.post(url, body, [{"Content-Type", "application/json"}, {"Authorization", fcm_key}])

    case Poison.decode(body) do
      #      needed to identify notification is sent or not, if not then no need to create notification
      [success: _count] when status_code > 200 ->
        {:ok, %{notification_map: notification_map, role: role}}

      _ ->
        {:ok, %{notification_map: notification_map, role: role}}
    end
  end

  defp create_local_push_notification(
         %{title: title, description: description, user_id: user_id, branch_id: branch_id},
         acl_role_id
       ) do
    params = %{
      user_id: user_id,
      branch_id: branch_id,
      acl_role_id: acl_role_id,
      title: title,
      description: description,
      pushed_at: DateTime.utc_now()
    }

    case Notifications.create_push_notification(params) do
      {:ok, notification} ->
        Notifications.get_trashable_push_notifications(user_id, acl_role_id)
        |> Enum.each(&Notifications.delete_push_notification(&1))

        #        I guess these three lines are not using because count is sending N_Ter in meta
        count =
          Notifications.get_unread_push_notifications_count_by_user_role(user_id, acl_role_id)

        CoreWeb.Endpoint.broadcast("unread_notifications_count", "unread_notifications_count", %{
          unread_notifications_count: count
        })

        {:ok, notification}

      _ ->
        {:error, ["notification not created!"]}
    end
  end

  defp create_local_push_notification(params, _role) do
    logger(__MODULE__, params, :info, __ENV__.line)
  end

  def update_cmr_meta(%{acl_role_id: "cmr", user_id: cmr_id}, count) do
    case MetaData.get_dashboard_meta_by_user_id(cmr_id, "dashboard") do
      [meta] ->
        if meta.statistics["n_ter"]["count"] >= 50 and count > 0 do
          {:ok, meta}
        else
          {_, updated_meta} =
            get_and_update_in(meta.statistics["n_ter"]["count"], &{&1, &1 + count})

          case MetaData.update_meta_cmr(meta, %{statistics: updated_meta.statistics}) do
            {:ok, data} ->
              Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_cmr_socket: "*")

              CoreWeb.Endpoint.broadcast("meta_cmr:user_id:#{cmr_id}", "meta_cmr", %{
                statistics: data.statistics
              })

              {:ok, data}

            _ ->
              {:ok, ["valid"]}
          end
        end

      _ ->
        {:ok, ""}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to update cmr meta"], __ENV__.line)
  end

  def update_cmr_meta(_, _), do: {:ok, "no need to update cmr meta"}

  def update_bsp_meta(%{acl_role_id: "bsp", user_id: user_id, branch_id: branch_id}, count)
      when is_integer(user_id) and is_integer(branch_id) do
    case Employees.get_owner_by_user_and_branch(user_id, branch_id) do
      %{id: id, branch_id: branch_id} ->
        case MetaData.get_dashboard_meta_by_employee_id(id, branch_id, "dashboard") do
          [] ->
            {:error, ["unable to find user meta"]}

          [meta] ->
            if meta.statistics["n_ter"]["count"] >= 50 and count > 0 do
              {:ok, meta}
            else
              {_, updated_meta} =
                get_and_update_in(meta.statistics["n_ter"]["count"], &{&1, &1 + count})

              case MetaData.update_meta_bsp(meta, %{statistics: updated_meta.statistics}) do
                {:ok, data} ->
                  Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_bsp_socket: "*")

                  CoreWeb.Endpoint.broadcast("meta_bsp:employee_id:#{id}", "meta_bsp", %{
                    statistics: data.statistics
                  })

                  {:ok, data}

                _ ->
                  {:ok, ["valid"]}
              end
            end

          _ ->
            {:error, ["something went wrong"]}
        end

      _ ->
        {:error, ["something went wrong"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["bid proposal not created"], __ENV__.line)
  end

  def update_bsp_meta(_, _), do: {:ok, "no need to update bsp meta"}

  def get_user_role(user_id) do
    case Accounts.get_user!(user_id) do
      %{acl_role_id: user_roles} ->
        cond do
          "bsp" in user_roles -> "bsp"
          "emp" in user_roles -> "emp"
          true -> "cmr"
        end

      _ ->
        "cmr"
    end
  end
end
