defmodule TudoChatWeb.GraphQL.UserSocket do
  @moduledoc false
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: TudoChatWeb.GraphQL.Schema
  import TudoChatWeb.Utils.Errors

  ## Channels
  channel "message_created:group_id:*", TudoChatWeb.Channels.MessageChannel
  channel "unread_group_messages:*", TudoChatWeb.Channels.UnreadGroupMessagesChannel
  channel "total_unread_messages:*", TudoChatWeb.Channels.TotalUnreadMessagesChannel
  channel "user:user_id:*", TudoChatWeb.Channels.UserChannel
  channel "call:group_id:*", TudoChatWeb.Channels.CallChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket, _connect_info) do
    logger(__MODULE__, token, :info, __ENV__.line)

    case TudoChatWeb.Guardian.decode_and_verify(token) do
      {:ok, data} ->
        {:ok, assign(socket, :user_id, data["sub"])}

      _ ->
        {:stop, {:shutdown, :closed}, socket}
        :error
    end
  end

  def connect(%{"Authorization" => auth} = _params, socket, _connect_info) do
    "Bearer " <> token = auth
    logger(__MODULE__, token, :info, __ENV__.line)

    case TudoChatWeb.Guardian.decode_and_verify(token) do
      {:ok, data} ->
        {:ok, assign(socket, :user_id, data["sub"])}

      _ ->
        :error
    end
  end

  #  def connect(params, socket, _connect_info) do
  #    {:ok, socket}
  #  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #       TudoChatWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  #  def id(_socket), do: nil
end
