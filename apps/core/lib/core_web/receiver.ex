defmodule CoreWeb.Receiver do
  @moduledoc false
  use Broadway
  import CoreWeb.Utils.Errors
  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producers: [
        default: [
          module: {
            BroadwaySQS.Producer,
            queue_name: Application.get_env(:core, :broker)[:queue_name],
            config: [
              access_key_id: Application.get_env(:core, :broker)[:access_key_id],
              secret_access_key: Application.get_env(:core, :broker)[:secret_access_key],
              region: Application.get_env(:core, :broker)[:region]
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
    logger(__MODULE__, message, :info, __ENV__.line)

    message
    |> Message.update_data(fn data -> data * data end)
  end

  def handle_message(_, message, _) do
    logger(__MODULE__, message, :info, __ENV__.line)
    message
  end

  def handle_batch(_, messages, _, _) do
    #    list = messages |> Enum.map(fn e -> e.data end)
    messages
  end
end
