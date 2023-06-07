defmodule CoreWeb.Endpoint do
  @moduledoc false
  use Phoenix.Endpoint, otp_app: :core
  use Absinthe.Phoenix.Endpoint
  # use Sentry.PlugCapture

  socket "/socket", CoreWeb.GraphQL.UserSocket,
    #    websocket: true,
    websocket: [
      timeout: :infinity
      #           subprotocols: ["sip", "mqtt"]
    ],
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :core,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    # 50MB
    parsers: [:urlencoded, {:multipart, length: 50_000_000}, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  # plug Sentry.PlugContext
  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_core_key",
    signing_salt: "3kubkPGO"

  plug CORSPlug,
    origin: ["http://localhost:4200", "https://admin.tudo.app", ~r/https?.*tudo\d?\.app$/]

  plug CoreWeb.Router
end
