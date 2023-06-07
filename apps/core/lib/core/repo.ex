defmodule Core.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :core,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 5
end
