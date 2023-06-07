defmodule TudoChatWeb.Plugs.Translation do
  @moduledoc false
  @locales ["en", "ur"]

  def init(default), do: default

  def call(%Plug.Conn{query_params: %{"lang" => loc}} = conn, _default) when loc in @locales do
    Gettext.put_locale(TudoChat.Gettext, loc)
    conn
  end

  def call(conn, default) do
    Gettext.put_locale(TudoChat.Gettext, default)
    conn
  end
end
