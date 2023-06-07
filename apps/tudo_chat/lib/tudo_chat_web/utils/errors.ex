defmodule TudoChatWeb.Utils.Errors do
  @moduledoc false
  import TudoChatWeb.Utils.Helpers, only: [error: 1]
  require Logger

  @doc """
      error helper to show the errors and inspect

    ##Examples

      ```elixir
        rescue
          exception ->
            logger(__MODULE__, exception, "SomeError that will be returned as tuple", 14)
            {:error, "SomeError that will be returned as tuple"}
      ```
  """
  @spec logger(module(), any(), any()) :: tuple()
  def logger(module, exception, err, line \\ 00) do
    Logger.error("""
    #{module}:#{line}
    #{inspect(exception, pretty: true)}
    """)

    err |> error
  end
end
