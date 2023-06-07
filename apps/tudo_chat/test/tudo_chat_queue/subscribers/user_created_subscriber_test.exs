defmodule TudoChatQueue.UserCreatedSubscriberTest do
  use ExUnit.Case
  use Conduit.Test
  import Conduit.Message
  alias Conduit.Message
  alias TudoChatQueue.UserCreatedSubscriber

  describe "process/2" do
    test "returns acked message" do
      message =
        %Message{}
        |> put_body("foo")

      assert %Message{status: :ack} = UserCreatedSubscriber.run(message)
    end
  end
end
