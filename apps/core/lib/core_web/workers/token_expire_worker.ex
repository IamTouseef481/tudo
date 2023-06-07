defmodule CoreWeb.Workers.TokenExpireWorker do
  @moduledoc false
  import CoreWeb.Utils.Errors
  alias Core.Emails

  @spec perform(any) :: {:error, any} | {:ok, any}
  def perform(id) do
    logger(__MODULE__, id, :info, __ENV__.line)

    token = Emails.get_random_token_by_id!(id)

    case Emails.update_random_tokens(token, %{expired: true}) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end
end
