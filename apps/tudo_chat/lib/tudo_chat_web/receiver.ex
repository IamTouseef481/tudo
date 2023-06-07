defmodule TudoChatWeb.Receiver do
  @moduledoc false
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producers: [
        default: [
          module: {
            BroadwaySQS.Producer,
            queue_name: Application.get_env(:tudo_chat, :broker)[:queue_name],
            config: [
              access_key_id: Application.get_env(:tudo_chat, :broker)[:access_key_id],
              secret_access_key: Application.get_env(:tudo_chat, :broker)[:secret_access_key],
              region: Application.get_env(:tudo_chat, :broker)[:region]
            ]
          },
          stages: 60
        ]
      ],
      processors: [
        default: [
          stages: 100
        ]
      ],
      batchers: [
        default: [
          stages: 80,
          batch_size: 10,
          batch_timeout: 2000
        ]
      ]
    )
  end

  def handle_message(_, %Message{data: _data} = message, _) do
    message
    |> Message.update_data(fn data -> data * data end)
  end

  def handle_message(_, _message, _) do
    #    receipt = %{
    #      id: message.metadata.message_id,
    #      receipt_handle: message.metadata.receipt_handle
    #    }

    # Do something with the receipt
  end

  def handle_batch(_, messages, _, _) do
    #    list = messages |> Enum.map(fn e -> e.data end)
    messages
  end
end
