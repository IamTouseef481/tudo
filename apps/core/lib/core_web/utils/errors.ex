defmodule CoreWeb.Utils.Errors do
  @moduledoc false
  import CoreWeb.Utils.Helpers, only: [error: 1]
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
  def logger(module, exception, match, line \\ 00)

  def logger(module, exception, :info, line) do
    Logger.info("""
      #{module}:#{line}
      #{inspect(exception, pretty: true)}
    """)

    exception
  end

  def logger(module, exception, err, line) do
    Logger.error("""
    #{module}:#{line}
    #{inspect(exception, pretty: true)}
    """)

    err |> error
  end
end
