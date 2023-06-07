defmodule CoreWeb.Sender do
  @moduledoc false
  import ExAws
  import CoreWeb.Queue

  def send(message) do
    "my_queue" |> send_message(message) |> request()
  end
end
