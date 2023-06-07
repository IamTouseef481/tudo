defmodule CoreWeb.Utils.Notification do
  @moduledoc false

  #  defstruct type: nil,
  #            description: nil,
  #            title: nil,
  #            image: "default",
  #            sound: "default",
  #            id: nil,
  #            badge: nil,
  #            user_id: nil,
  #            time: nil

  def apns(notification, device_token, _package_name) do
    make_notification(notification, device_token)

    #    Pigeon.APNS.Notification.new(
    #      %{"title" => notification.title, "body" => notification.description},
    #      device_token,
    #      package_name
    #    )
    #    |> Pigeon.APNS.Notification.put_badge(notification.badge)
    #    |> Pigeon.APNS.Notification.put_mutable_content()
    #    |> Pigeon.APNS.Notification.put_sound(notification.sound)
    #    |> Pigeon.APNS.Notification.put_custom(%{
    #      "data" => %{
    #        "type" => notification.type,
    #        "id" => notification.id,
    #        "image" => notification.image,
    #        "time" => notification.time,
    #        "user_id" => notification.user_id
    #      }
    #    })
  end

  def apns_silent(notification, device_token, package_name),
    do: apns(notification, device_token, package_name)

  def fcm(notification, device_token) do
    make_notification(notification, device_token)

    #    msg = %{
    #      "body" => notification.description,
    #      "title" => notification.title,
    #      "sound" => notification.sound
    #    }
    #
    #    Pigeon.FCM.Notification.new(device_token, msg)
    #    |> Pigeon.FCM.Notification.put_data(%{
    #      "type" => notification.type,
    #      "id" => notification.id,
    #      "time" => notification.time,
    #      "image" => notification.image,
    #      "user_id" => notification.user_id
    #    })
  end

  def fcm_data_msg(notification, device_token) do
    make_notification(notification, device_token)

    #    Pigeon.FCM.Notification.new(device_token, nil)
    #    |> Pigeon.FCM.Notification.put_data(%{
    #      "sound" => notification.sound,
    #      "body" => notification.description,
    #      "title" => notification.title,
    #      "type" => notification.type,
    #      "id" => notification.id,
    #      "time" => notification.time,
    #      "image" => notification.image,
    #      "user_id" => notification.user_id
    #    })
  end

  defp make_notification(notification, device_token) do
    {:ok, body} =
      Poison.encode(%{
        to: device_token,
        priority: "high",
        notification: %{
          body: notification.description,
          title: notification.title,
          sound: "default",
          badge: 0
        },
        data: %{
          payment_id: notification.payment_id,
          click_action: notification.click_action,
          screen: notification.screen,
          extra_data: notification.extra_data,
          type: notification.type,
          id: notification.id,
          image: notification.image,
          time: notification.time,
          user_id: notification.user_id,
          call_initiator_detail: notification[:call_initiator_detail]
        }
      })

    body
  end

  @doc """
  device_exists?/2

  Checks if the requesting device exists or not.

  TODO: implement the web version as well.
  """

  def device_exists?(device_id, device_type) do
    case device_type do
      "android" ->
        CoreWeb.Utils.FCM.device_exists?(device_id)

      "ios" ->
        CoreWeb.Utils.Apns.device_exists?(device_id)

      "web" ->
        true
    end
  end
end
