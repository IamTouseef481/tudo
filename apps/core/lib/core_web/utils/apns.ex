defmodule CoreWeb.Utils.Apns do
  @moduledoc false

  def device_exists?(device_id) do
    package_name = Application.get_env(:core, :package)[Mix.env()]

    pn = Pigeon.APNS.Notification.new(nil, device_id, package_name)
    pn = pn |> Pigeon.APNS.Notification.put_content_available()

    %Pigeon.APNS.Notification{
      device_token: _device_id,
      expiration: _exp,
      id: _apns_id,
      payload: _payload,
      response: response,
      topic: _topic
    } = Pigeon.APNS.push(pn, to: apns_config(package_name))

    #    pn_string=pn |>
    #      Map.from_struct()|>map_to_string()
    #    Random.send_email(
    #      "hammad@limblo.net",
    #      "Notification request "<> Atom.to_string(response),
    #      "package_name: "<>package_name<>"<br>"<>
    #      "device_id: "<>device_id<>"<br>"<>
    #      "pn: "<>pn_string<>"<br>"<>
    #      "app: "<>app<>"<br>"<>
    #      "apns_package: "<>Atom.to_string(apns_config(package_name))<>"</br>"
    #    )

    case response do
      :success -> true
      _ -> false
    end
  end

  def apns_config(package) do
    case package do
      "app.tudo.dev" ->
        :apns_tudo_dev

      "app.tudo.prod" ->
        :apns_tudo_prod

      _ ->
        :apns_default
    end
  end

  def map_to_string(struct) do
    struct
    |> Enum.map_join(fn {key, value} ->
      String.Chars.to_string(key) <>
        ":" <> if is_map(value), do: map_to_string(value), else: String.Chars.to_string(value)
    end)
  end
end
