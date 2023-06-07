defmodule TudoChatWeb.Sender do
  @moduledoc false
  import ExAws
  import TudoChatWeb.Queue

  def send(message) do
    "my_queue" |> send_message(message) |> request()
  end
end
