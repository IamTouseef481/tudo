# credo:disable-for-this-file
defmodule CoreWeb.Plugs.Translation do
  @moduledoc false
  import Plug.Conn
  import CoreWeb.Utils.CommonFunctions

  @url_key Application.get_env(:core, :gettext)[:url_key]
  @locales Application.get_env(:core, :gettext)[:locales]

  def init(default), do: default

  def call(%Plug.Conn{query_params: %{@url_key => loc}} = conn, _default) when loc in @locales do
    Gettext.put_locale(CoreWeb.Gettext, loc)
    register_request(conn, loc)
  end

  def call(conn, default) do
    Gettext.put_locale(CoreWeb.Gettext, default)
    register_request(conn, default)
  end

  def register_request(conn, prev_locale) do
    register_before_send(conn, fn conn ->
      case get_req_header(conn, "content-type") do
        [content_type] ->
          if String.contains?(content_type, "application/json") do
            encode_translate_decode(conn, prev_locale)
          else
            conn
          end

        _ ->
          conn
      end
    end)
  end

  defp encode_translate_decode(conn, prev_locale) do
    case decode(conn.resp_body) do
      {:error, _} ->
        conn

      decoded_resp ->
        case decoded_resp["data"] do
          %{"__schema" => _} ->
            conn

          _ ->
            translation = translate(decoded_resp, prev_locale)
            #            get_non_translated_slugs(translation)
            resp(conn, conn.status, Poison.encode!(translation))
        end
    end
  end

  #  def translate({msg, opts}) do
  #    cond do
  #      count = opts[:count] -> Gettext.dngettext(CoreWeb.Gettext, "errors", msg, msg, count, opts)
  #      number = opts[:number] -> Gettext.dngettext(CoreWeb.Gettext, "errors", msg, msg, number, opts)
  #      msg -> translate(msg)
  #    end
  #  end

  def translate(%{"errors" => errors} = data, prev_locale) when is_list(errors) do
    Map.merge(data, %{"errors" => translating(errors, "errors", [], prev_locale)})
  end

  def translate(%{"errors" => error} = data, prev_locale) when is_map(error) do
    Map.merge(data, %{"errors" => translating(error, "errors", [], prev_locale)})
  end

  def translate(%{"errors" => error} = data, prev_locale) when is_binary(error) do
    Map.merge(data, %{"errors" => translating(error, "errors", [], prev_locale)})
  end

  def translate(data, prev_locale) when is_list(data) do
    translating(data, "general", [], prev_locale)
  end

  def translate(data, prev_locale) when is_map(data) do
    translating(data, "general", [], prev_locale)
  end

  def translate(data, prev_locale) when is_binary(data) do
    translating(data, "general", [], prev_locale)
  end

  def translate(data, _prev_locale) do
    data
  end

  defp translating(value, translation_type, args, prev_locale) when is_list(value) do
    Enum.map(value, &translating(&1, translation_type, args, prev_locale))
  end

  defp translating(value, translation_type, args, prev_locale) when is_map(value) do
    slugs_not_to_be_ignored = [
      "app_id",
      "other_id",
      "transaction_id",
      "paypal_email_id",
      "business_registration_id",
      "paypal_account_id",
      "agent_email_id"
    ]

    Enum.reduce(value, %{}, fn {key, val}, acc ->
      #      app_id id a single key which needs to be translated and all other _id fields not because they are foreign keys
      if to_string(key) in ["slug", "id", "type", "update_status_by", "user_role"] ||
           (String.ends_with?(Recase.to_snake(to_string(key)), "_id") &&
              key not in slugs_not_to_be_ignored) do
        Map.merge(acc, %{"#{key}" => val})
      else
        Map.merge(acc, %{"#{key}" => translating(val, translation_type, args, prev_locale)})
      end
    end)
  end

  defp translating(value, translation_type, args, prev_locale) when is_binary(value) do
    translated_str = Gettext.dgettext(CoreWeb.Gettext, translation_type, value, args)

    if translated_str != value do
      translated_str
    else
      Gettext.put_locale(CoreWeb.Gettext, "en")
      eng_translated_str = Gettext.dgettext(CoreWeb.Gettext, translation_type, value, args)
      Process.delete(Gettext)
      Gettext.put_locale(CoreWeb.Gettext, prev_locale)
      eng_translated_str
    end
  end

  defp translating(value, _translation_type, _args, _prev_locale) do
    value
  end

  #  defp get_non_translated_slugs(translation) do
  #    Enum.reduce(translation["data"]["translations"], [],
  #      fn {_, v}, acc ->
  #        Enum.reduce(v, acc, fn {_, val}, acc2 ->
  #          if String.contains?(val["translation"], "_") do
  #            [val["translation"] | acc2]
  #          else
  #            acc2
  #          end
  #        end)
  #      end
  #    )
  #  end
end
