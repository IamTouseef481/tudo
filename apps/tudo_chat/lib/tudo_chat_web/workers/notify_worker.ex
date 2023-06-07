defmodule TudoChatWeb.Workers.NotifyWorker do
  @moduledoc false
  import TudoChatWeb.Utils.Errors

  def perform(user_ids, message, %{"user_from" => user_from}, silent_push \\ false) do
    #    %{device_info: %{"manufacture" => device}, fcm_token: device_id} = Core.Accounts.get_user_installs_by_user_id(user_id)

    Enum.map(user_ids, fn user_id ->
      Enum.map(Core.Accounts.get_user_installs_by_user(user_id), fn install ->
        %{os: device, fcm_token: device_id} = install

        send_notification_for_single_device(
          user_id,
          message,
          silent_push,
          device,
          device_id,
          user_from
        )
      end)
    end)
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)

      {:ok, ["error in notification worker"]}
  end

  defp send_notification_for_single_device(
         user_id,
         message,
         silent_push,
         device,
         device_id,
         user_from
       ) do
    %{profile: %{"first_name" => f_name, "last_name" => l_name}} =
      Core.Accounts.get_user!(user_from)

    identify_url = Application.get_env(:tudo_chat, :identify_host_url)

    notification =
      if identify_url == "localhost" do
        %{body: "Test Server:" <> message, title: "#{f_name} #{l_name}", user_id: user_id}
      else
        %{body: message, title: "#{f_name} #{l_name}", user_id: user_id}
      end

    cond do
      device == nil ->
        logger(__MODULE__, "User have no device id linked", :info, __ENV__.line)
        false

      String.contains?(device, ["android", "Android", "ANDROID"]) ->
        n =
          if silent_push do
            make_notification_body(notification, device_id)
          else
            make_notification_body(notification, device_id)
          end

        send_notification(device_id, n)

      String.contains?(device, ["ios", "Ios", "IOS"]) ->
        #        package_name = Application.get_env(:tudo_chat, :package)[Mix.env]
        n =
          if silent_push do
            make_notification_body(notification, device_id)
          else
            make_notification_body(notification, device_id)
          end

        send_notification(device_id, n)

      true ->
        {:error, ["Device not correct or not supported"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["error in send_notification_for_single_device fun"]}
  end

  defp send_notification(_device_id, body) do
    #    fcm_key = "key="<>Application.get_env(:pigeon, :fcm)[Mix.env][:key]
    fcm_key =
      "key=AAAA2OLN994:APA91bHqwgmsmu0-0ySbi032c3D4ly6CFzoTWlIcRmk40aVjzbmCj0kFn1y7dfmAzk66FD_6TntFE31MkwmmAeSouVTXEP_pE8QcT0l038ufX6OyK6cvOwHdNuTWg4qQPXO1IuXRgS3h"

    url = "https://fcm.googleapis.com/fcm/send"

    {:ok, %{body: body, status_code: status_code}} =
      HTTPoison.post(url, body, [{"Content-Type", "application/json"}, {"Authorization", fcm_key}])

    case Poison.decode(body) do
      [success: _count] when status_code > 200 -> {:ok, ["notification has sent!"]}
      _ -> {:ok, ["notification hasn't sent!"]}
    end
  end

  def make_notification_body(notification, device_token) do
    default_msg = %{
      type: nil,
      message: nil,
      image: "default",
      sound: "default",
      id: nil,
      badge: nil,
      user_id: nil,
      time: nil
    }

    notification = Map.merge(default_msg, notification)

    {:ok, body} =
      Poison.encode(%{
        to: device_token,
        priority: "high",
        notification: %{
          body: notification.body,
          title: notification.title,
          user_id: notification.user_id,
          sound: "default",
          badge: 0
        },
        data: %{
          type: notification.type,
          id: notification.id,
          image: notification.image,
          time: notification.time,
          user_id: notification.user_id
        }
      })

    body
  end
end
