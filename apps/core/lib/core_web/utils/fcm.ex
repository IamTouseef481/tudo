defmodule CoreWeb.Utils.FCM do
  @moduledoc false
  # app = "provider"
  # device_id = "eyw0vLYeH_U:APA91bEqhI0ggbTr0WqX3trPnKc99VEyyCdXgZefpUHEkUfP2Th3lQeM-hzbTbcPHsirwaNf1XscQcld9o5mmIwBQuZbiq8OUfr_duDxetWpVjQdBJrSRHPg1CxrZHuwwyijgsygqFRT"
  # %Pigeon.FCM.Notification{message_id: message_id, response: response, status: status} = FCM.device_exists?(device_id, app)

  def device_exists?(device_id, dry_run \\ true) do
    # https://firebase.google.com/docs/cloud-messaging/http-server-ref#downstream-http-messages-json
    # Test notification this way https://github.com/codedge-llc/pigeon/issues/71

    # You can send data this way
    data = %{"key" => "value"}
    pn = Pigeon.FCM.Notification.new(device_id, %{"body" => "msg_body"}, data)
    payload = Map.put(pn.payload, :dry_run, dry_run)
    pn = Map.put(pn, :payload, payload)

    %Pigeon.FCM.Notification{message_id: _msg_id, response: response, status: _status} =
      Pigeon.FCM.push(
        pn,
        key: Application.get_env(:pigeon, :fcm)[Mix.env()][:key]
      )

    case response do
      [success: _device_id] -> true
      _ -> false
    end
  end
end
