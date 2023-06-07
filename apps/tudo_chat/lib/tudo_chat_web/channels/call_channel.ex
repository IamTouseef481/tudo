defmodule TudoChatWeb.Channels.CallChannel do
  @moduledoc false
  use TudoChatWeb, :channel
  # alias TudoChatWeb.Controllers.MessageController
  alias TudoChatWeb.Channels.Presence
  alias TudoChat.Calls.CallMeta
  alias TudoChat.Messages
  alias TudoChatWeb.Utils.CommonFunctions

  def join("call:group_id:" <> group_id, _payload, socket) do
    user_id = socket.assigns[:user_id]

    case authorized?(%{"group_id" => group_id, "user_id" => user_id}) do
      true ->
        {:ok, socket}

      _ ->
        {:error, %{reason: "you're not member of this group"}}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        %{reason: "something wrong in joining message channel"},
        __ENV__.line
      )
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (job:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("phx_close", _payload, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  # Channels can be used in a start call
  def handle_in(
        "call_start",
        %{
          "participant_ids" => participant_ids
        } = payload,
        socket
      ) do
    initiator_id = socket.assigns[:user_id] |> String.to_integer()
    group_id = String.split(socket.topic, ":") |> List.last() |> String.to_integer()

    with {:ok, call} <-
           Messages.create_call(%{
             initiator_id: initiator_id,
             group_id: group_id
           }),
         {:ok, _call_meta} <-
           Messages.create_call_meta(%{
             call_id: call.id,
             status: "call_start",
             admin: true,
             participant_id: initiator_id
           }),
         :ok <-
           Enum.each(participant_ids, fn participant_id ->
             Messages.create_call_meta(%{
               call_id: call.id,
               status: "ringing",
               admin: false,
               participant_id: participant_id
             })

             Task.start(
               CoreWeb.Workers.NotifyWorker,
               :perform,
               [
                 "call",
                 to_string(participant_id),
                 "EN",
                 "cmr",
                 %{
                   call_initiator_detail:
                     make_notification_response(initiator_id, payload)
                     |> CommonFunctions.camel_keys_to_snake()
                 }
               ]
             )

             TudoChatWeb.Endpoint.broadcast(
               "user:user_id:#{participant_id}",
               "in_coming_call",
               make_notification_response(participant_id, payload)
               |> CommonFunctions.snake_keys_to_camel()
             )
           end) do
      Exq.enqueue_at(
        Exq,
        "default",
        Timex.now() |> Timex.shift(seconds: 30),
        "TudoChatWeb.Workers.CallWorker",
        [call.id, participant_ids, initiator_id]
      )

      Presence.track(socket, initiator_id |> to_string, %{})

      {:reply, {:ok, %{call_id: call.id}}, socket}
    else
      _ -> {:error, %{reason: ["something went wrong"]}}
    end
  end

  # Channels can be used in a call_received, call_declined and call_missed
  def handle_in(
        "call_response",
        %{"call_id" => call_id, "status" => status} = payload,
        socket
      ) do
    receiver_id = socket.assigns[:user_id]
    initiator_call_meta = Messages.get_initiator_meta_by_call_id_and_status(call_id)
    %{group_id: group_id} = Messages.get_group_id_by_call_id(call_id)

    if status == "received" do
      case Messages.get_call_meta_by_call_id_and_user_id(call_id, receiver_id) do
        nil ->
          {:reply, {:error, %{error: "Call does not exist against this call_id"}}, socket}

        %{admin: true} ->
          {:reply, {:error, %{error: "you cannot pick your own call"}}, socket}

        %{status: "missed"} ->
          {:reply, {:error, %{error: "This call has been missed"}}, socket}

        %{status: "declined"} ->
          {:reply, {:error, %{error: "This call has been declined"}}, socket}

        %{status: "received"} ->
          {:reply, {:error, %{error: "This call has been already taken"}}, socket}

        %{admin: false} ->
          Presence.track(socket, receiver_id, %{})

          %{
            call_id: call_id,
            status: status,
            call_start_time: DateTime.utc_now(),
            participant_id: receiver_id,
            initiator_call_meta: initiator_call_meta
          }
          |> update_call_meta(socket)
          |> send_broadcast_and_socket_response(%{
            sokcet: socket,
            group_id: group_id,
            payload: payload,
            call_id: call_id
          })
      end
    else
      %{
        call_id: call_id,
        status: status,
        participant_id: receiver_id
      }
      |> update_call_meta(socket)
    end
  end

  # Channels can be used in a call_ends
  def handle_in(
        "call_end",
        %{"call_id" => call_id} = payload,
        socket
      ) do
    %{group_id: group_id} = Messages.get_group_id_by_call_id(call_id)

    %{
      call_id: call_id,
      status: "ended",
      participant_id: socket.assigns[:user_id] |> String.to_integer(),
      call_end_time: DateTime.utc_now()
    }
    |> update_call_meta_when_call_ended(socket)
    |> send_broadcast_and_socket_response(%{
      sokcet: socket,
      group_id: group_id,
      payload: payload,
      call_id: call_id
    })
  end

  def handle_in(_event, _payload, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  def terminate(_reason, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(%{"user_id" => user_id, "group_id" => group_id} = _payload) do
    case TudoChat.Groups.get_active_group_member_by(%{user_id: user_id, group_id: group_id}) do
      [] -> false
      _user -> true
    end
  end

  def update_call_meta(%{initiator_call_meta: initiator_call_meta} = params, socket) do
    with %CallMeta{} = call_meta <-
           get_call_meta_by_call_id_and_user_id(params.call_id, params.participant_id),
         {:ok, %CallMeta{}} <-
           Messages.update_call_meta(
             call_meta,
             Map.drop(params, [:initiator_call_meta, :call_id, :participant_id])
           ),
         {:ok, %CallMeta{} = initiator_call_meta} <-
           Messages.update_call_meta(initiator_call_meta, %{
             call_start_time: DateTime.utc_now(),
             status: "received"
           }) do
      %{
        receivers: Messages.get_received_call_meta_by_call_id(params.call_id),
        initiator: %{
          status: initiator_call_meta.status,
          call_start_time: initiator_call_meta.call_start_time,
          participant_id: initiator_call_meta.participant_id
        },
        ended: nil
      }
    else
      _ -> {:reply, {:error, %{error: "something went wrong"}}, socket}
    end
  end

  def update_call_meta(params, socket) do
    with %CallMeta{} = call_meta <-
           Messages.get_call_meta_by_call_id_and_user_id(params.call_id, params.participant_id),
         {:ok, %CallMeta{} = data} <-
           Messages.update_call_meta(
             call_meta,
             Map.drop(params, [:initiator_call_meta, :call_id, :participant_id])
           ) do
      {:reply, {:ok, %{call_id: data.call_id}}, socket}
    else
      _ -> {:reply, {:error, %{error: "something went wrong"}}, socket}
    end
  end

  def update_call_meta_when_call_ended(params, socket) do
    %{group_id: group_id} = Messages.get_group_id_by_call_id(params.call_id)

    Presence.untrack(
      socket.channel_pid,
      "call:group_id:#{group_id}",
      params.participant_id |> to_string
    )

    after_untrack = Presence.list(socket)

    with %CallMeta{} = call_meta <-
           get_call_meta_by_call_id_and_user_id(params.call_id, params.participant_id),
         :ok <-
           check_previous_status_before_update_call_meta(call_meta.status) do
      data_for_update =
        Map.merge(params, %{
          call_duration:
            DateTime.diff(params.call_end_time, call_meta.call_start_time)
            |> CommonFunctions.convert_string_time_to_time_format(),
          status: "ended"
        })

      update_on_call_end(
        call_meta,
        Map.drop(data_for_update, [:participant_id, :call_id]),
        socket
      )

      if Enum.count(after_untrack) == 1 do
        update_on_call_end(call_meta, data_for_update, socket)

        update_last_user(
          Map.keys(after_untrack) |> List.first() |> String.to_integer(),
          params.call_id,
          data_for_update,
          socket
        )

        last_user_in_presence = Map.keys(after_untrack) |> List.first()
        Presence.untrack(socket.channel_pid, "call:group_id:#{group_id}", last_user_in_presence)
      else
        make_admin_random(socket, call_meta, data_for_update, group_id)
      end

      initiator_call_meta = Messages.get_initiator_meta_by_call_id_and_status(params.call_id)

      %{
        receivers: Messages.get_received_call_meta_by_call_id(params.call_id),
        initiator: %{
          status: initiator_call_meta.status,
          call_start_time: initiator_call_meta.call_start_time,
          participant_id: initiator_call_meta.participant_id
        },
        ended: Messages.get_ended_call_meta_by_call_id(params.call_id, socket.assigns[:user_id])
      }
    else
      _ -> {:reply, {:error, %{error: "something went wrong"}}, socket}
    end
  end

  def check_previous_status_before_update_call_meta(prev_status) do
    if prev_status == "received" do
      :ok
    else
      :error
    end
  end

  def make_admin_random(socket, %{admin: admin} = call_meta, data_for_update, _group_id) do
    if admin == false do
      update_on_call_end(call_meta, data_for_update, socket)
    else
      case get_call_meta_by_call_id_and_user_id(
             data_for_update[:call_id],
             Presence.list(socket) |> Map.keys() |> List.first() |> String.to_integer()
           ) do
        nil ->
          {:reply, {:error, %{error: "Error in getting in call users"}}, socket}

        %{admin: false} = data ->
          case Messages.update_call_meta(
                 data,
                 %{admin: true}
               ) do
            {:ok, %CallMeta{} = data} ->
              {:reply, {:ok, data.call_id}, socket}

            _ ->
              {:reply, {:error, %{error: "Error during updating call meta"}}, socket}
          end
      end
    end
  end

  def update_last_user(user_id, call_id, data_for_update, socket) do
    get_call_meta_by_call_id_and_user_id(call_id, user_id)
    |> update_on_call_end(data_for_update, socket)
  end

  def get_call_meta_by_call_id_and_user_id(call_id, participant_id) do
    case Messages.get_call_meta_by_call_id_and_user_id(call_id, participant_id) do
      nil -> nil
      data -> data
    end
  end

  def update_on_call_end(call_meta, data_for_update, socket) do
    case Messages.update_call_meta(call_meta, data_for_update) do
      {:ok, %CallMeta{} = data} ->
        {:reply, {:ok, data.call_id}, socket}

      _ ->
        {:reply, {:error, %{error: "Error during updating call meta"}}, socket}
    end
  end

  def send_broadcast_and_socket_response(
        %{receivers: receivers, initiator: initiator, ended: ended},
        %{
          sokcet: socket,
          group_id: group_id,
          payload: payload,
          call_id: call_id
        }
      ) do
    receivers =
      Enum.map(receivers, fn %{participant_id: participant_id} = receivers ->
        apply(CoreWeb.Utils.CommonFunctions, :snake_keys_to_camel, [receivers])
        |> Map.drop([:participantId])
        |> Map.merge(apply(Core.Accounts, :get_user_short_object_for_socket, [participant_id]))
      end)

    initiator =
      Map.merge(
        apply(CoreWeb.Utils.CommonFunctions, :snake_keys_to_camel, [initiator]),
        apply(Core.Accounts, :get_user_short_object_for_socket, [initiator.participant_id])
        |> Map.drop(["participantId"])
      )

    ended =
      if is_nil(ended) do
        nil
      else
        Map.merge(
          apply(CoreWeb.Utils.CommonFunctions, :snake_keys_to_camel, [ended]),
          apply(Core.Accounts, :get_user_short_object_for_socket, [ended.participant_id])
        )
        |> Map.drop(["participantId"])
      end

    payload = Map.merge(payload, %{receivers: receivers, initiator: initiator, ended: ended})

    TudoChatWeb.Endpoint.broadcast("call:group_id:#{group_id}", "call_response", payload)

    {:reply, {:ok, %{call_id: call_id}}, socket}
  end

  def send_broadcast_and_socket_response(data, _), do: data

  def make_notification_response(user_id, payload) do
    Map.merge(
      apply(Core.Accounts, :get_user_short_object_for_socket, [user_id]),
      payload
    )
  end
end
