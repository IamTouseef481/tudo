# credo:disable-for-this-file
defmodule Acl.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :acl,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
