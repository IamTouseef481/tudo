defmodule TudoChatWeb.GraphQL.Resolvers.ChannelResolver do
  @moduledoc false
  def channels(_, _, _) do
    {:ok, TudoChat.Channels.list_channels()}
  end

  def create_channel(_, %{input: input}, _) do
    TudoChat.Channels.create_channel(input)
  end
end
