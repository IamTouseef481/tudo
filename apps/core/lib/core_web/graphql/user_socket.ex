defmodule CoreWeb.GraphQL.UserSocket do
  @moduledoc false
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: CoreWeb.GraphQL.Schema
  import CoreWeb.Utils.Errors

  ## Channels
  channel "job:*", CoreWeb.Channels.JobChannel
  channel "order:*", CoreWeb.Channels.OrderChannel
  channel "meta_bsp:*", CoreWeb.Channels.MetaBspChannel
  channel "meta_cmr:*", CoreWeb.Channels.MetaCmrChannel
  channel "employee:*", CoreWeb.Channels.EmployeeChannel
  channel "unread_notifications_count", CoreWeb.Channels.PushNotificationChannel
  channel "cash_payment:*", CoreWeb.Channels.CashPaymentChannel

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

    case CoreWeb.Guardian.decode_and_verify(token) do
      {:ok, data} ->
        {:ok, assign(socket, :user_id, data["sub"])}

      _ ->
        {:stop, {:shutdown, :closed}, socket}
        :error
    end
  end

  def connect(%{"Authorization" => auth}, socket, _connect_info) do
    "Bearer " <> token = auth

    logger(__MODULE__, token, :info, __ENV__.line)

    case CoreWeb.Guardian.decode_and_verify(token) do
      {:ok, data} ->
        {:ok, assign(socket, :user_id, data["sub"])}

      _ ->
        #        {:stop, {:shutdown, :closed}, socket}
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
  #       CoreWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  #  def id(_socket), do: nil
end
