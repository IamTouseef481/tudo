defmodule TudoChat.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :tudo_chat,
    adapter: Ecto.Adapters.Postgres

  #  use Scrivener, page_size: 5
end
