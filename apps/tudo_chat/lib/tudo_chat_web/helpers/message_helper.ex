defmodule TudoChatWeb.Helpers.MessageHelper do
  @moduledoc false
  use TudoChatWeb, :chat_helper
  alias TudoChat.{Groups, Messages}
  alias TudoChatWeb.Channels.{Presence, UserChannel}

  def create_com_group_message(params) do
    new()
    |> run(:verify_sender, &verify_sender/2, &abort/3)
    |> run(:verify_active_group, &verify_active_group/2, &abort/3)
    |> run(:block_forward_message, &block_forwarding_message_in_bus_net/2, &abort/3)
    #    |> run(:verify_message_request, &verify_message_request/2, &abort/3)
    |> run(:message_tags_verification, &message_tags_verification/2, &abort/3)
    |> run(:message, &create_message/2, &abort/3)
    #    |> run(:message_tags, &create_message_tags/2, &abort/3)
    |> run(:message_socket, &create_message_socket/2, &abort/3)
    |> run(:message_meta, &create_message_meta/2, &abort/3)
    |> run(:message_notification, &send_message_notification/2, &abort/3)
    |> run(:update_group, &update_group/2, &abort/3)
    |> transaction(TudoChat.Repo, params)
  end

  # -----------------------------------------------

  defp verify_sender(_, %{marketing_group: true}) do
    {:ok, ["member"]}
  end

  defp verify_sender(_, %{group_id: group_id, user_from_id: user_id}) do
    member_user_ids = Groups.get_active_group_member_user_ids_by_group(group_id)
    #    member_user_ids = Enum.map(members, & &1.user_id)
    if user_id in member_user_ids,
      do: {:ok, ["member"]},
      else: {:error, ["you're not member of this group"]}
  end

  defp verify_active_group(_, %{group_id: group_id}) do
    case Groups.get_group(group_id) do
      nil ->
        {:error, ["chat group not found"]}

      %{group_status_id: "active"} ->
        {:ok, ["active group"]}

      exception ->
        logger(__MODULE__, exception, ["Chat group is not active"], __ENV__.line)
    end
  end

  defp block_forwarding_message_in_bus_net(_, %{group_id: group_id, forwarded: true}) do
    case Groups.get_group(group_id) do
      %{group_type_id: type} ->
        if type == "bus_net" do
          {:error, ["forwarding messages in not allowed"]}
        else
          {:ok, ["valid"]}
        end

      exception ->
        logger(__MODULE__, exception, ["Error in fetching chat group!"], __ENV__.line)
    end
  end

  defp block_forwarding_message_in_bus_net(_, _) do
    {:ok, ["valid"]}
  end

  #  defp verify_message_request(_, %{group_id: group_id}=params) do
  #    case Groups.get_group(group_id) do
  #      %{group_type_id: type} ->
  #        if type == "bus_net" do
  #          {:ok, ["valid"]}
  #        else
  #          case FriendCircles.get_friend_circles_by(params) do
  #            [] -> {:error, ["message request not accepted!"]}
  #            requests ->
  #               check specific request accepted or not, not any of this user
  #              {:ok, requests}
  #          end
  #        end
  #      _ -> {:error, ["error in fetching chat group!"]}
  #    end
  #  end

  defp message_tags_verification(_, %{tagged_user_ids: _user_ids} = input) do
    with {:ok, input} <- verify_number_of_members_tagging(input),
         {:ok, _users} <- verify_users(input),
         {:ok, _users} <- verify_group_members(input) do
      {:ok, ["valid"]}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Unexpected error occurred"], __ENV__.line)
    end
  end

  defp message_tags_verification(_, _input) do
    {:ok, ["valid"]}
  end

  def add_group_id_to_params(%{message_id: message_id} = input) do
    case Messages.get_com_group_message(message_id) do
      %{group_id: group_id} ->
        {:ok, Map.merge(input, %{group_id: group_id})}

      exception ->
        logger(__MODULE__, exception, ["Error in fetching message"], __ENV__.line)
    end
  end

  defp verify_number_of_members_tagging(%{tagged_user_ids: tagged_user_ids} = input) do
    count = tagged_user_ids |> Enum.uniq() |> Enum.count()
    if count <= 10, do: {:ok, input}, else: {:error, ["tagging more than 10 user not allowed"]}
  end

  defp verify_users(%{tagged_user_ids: tagged_user_ids} = _input) do
    data =
      Enum.reduce_while(tagged_user_ids, tagged_user_ids, fn tagged_user_id, acc ->
        if false == is_nil(apply(Core.Accounts, :get_user!, [tagged_user_id])) do
          {:cont, acc}
        else
          {:halt, {:error, ["tagging user id #{tagged_user_id} does not exist"]}}
        end
      end)

    case data do
      {:error, error} -> {:error, error}
      data -> {:ok, data}
    end
  end

  defp verify_group_members(%{tagged_user_ids: tagged_user_ids, group_id: group_id} = _input) do
    data =
      Enum.reduce_while(tagged_user_ids, tagged_user_ids, fn tagged_user_id, acc ->
        if Groups.get_group_member_by(%{group_id: group_id, user_id: tagged_user_id}) != [] do
          {:cont, acc}
        else
          {:halt, {:error, ["tagging user id #{tagged_user_id} is not member of this group"]}}
        end
      end)

    case data do
      {:error, error} -> {:error, error}
      data -> {:ok, data}
    end
  end

  defp create_message(_, params) do
    params = add_job_status_id(params)
    params = Map.merge(params, %{created_at: DateTime.utc_now()})

    params =
      case params do
        %{tagged_user_ids: tagged_users} ->
          Map.merge(params, %{tagged_user_ids: Enum.uniq(tagged_users)})

        params ->
          params
      end

    case Messages.create_com_group_message(params) do
      {:ok, message} ->
        {:ok, message}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["Something went wrong while creating message"],
          __ENV__.line
        )
    end
  end

  #  defp create_message_tags(%{message: %{id: message_id}}, params) do
  #    case params do
  #      %{tagged_user_ids: user_ids} ->
  #        params = %{user_to_ids: user_ids, message_id: message_id, user_from_id: params.user_from_id}
  #        case TagController.create_tags(params) do
  #          {:ok, tag} -> {:ok, tag}
  #          {:error, error} -> {:error, error}
  #          _ -> {:error, ["error occurred while creating tag!"]}
  #        end
  #      _ -> {:ok, %{user_to_ids: []}}
  #    end
  #  end

  defp add_job_status_id(%{group_id: group_id} = params) do
    case Groups.get_group(group_id) do
      %{service_request_id: nil} ->
        params

      %{service_request_id: job_id} ->
        case apply(Core.Jobs, :get_job, [job_id]) do
          %{job_status_id: job_status_id} -> Map.merge(params, %{job_status_id: job_status_id})
          _ -> params
        end

      _ ->
        params
    end
  end

  defp add_job_status_id(params), do: params

  defp create_message_socket(%{message: message}, _params) do
    message_for_rest_socket = UserChannel.create_message_socket(message)

    with :ok <-
           Absinthe.Subscription.publish(TudoChatWeb.Endpoint, message,
             message_created: message.group_id
           ),
         :ok <-
           TudoChatWeb.Endpoint.broadcast(
             "message_created:group_id:#{message.group_id}",
             "message_created",
             %{message_created: message_for_rest_socket}
           ) do
      {:ok, Map.merge(message, %{sent: true})}
    else
      _ -> {:ok, Map.merge(message, %{sent: false})}
    end
  end

  defp create_message_meta(
         %{
           message: message_struct,
           message_socket: %{
             id: message_id,
             message: _message,
             user_from_id: sender_user_id,
             sent: sent
           }
         },
         %{group_id: group_id}
       ) do
    group_type =
      case Groups.get_group(group_id) do
        %{group_type_id: group_type} -> group_type
        _ -> nil
      end

    members = Groups.get_group_members_by_group(group_id)
    message_for_rest_socket = UserChannel.create_message_socket(message_struct)

    online_users =
      Presence.list("message_created:group_id:#{group_id}")
      |> Map.keys()
      |> Enum.map(&String.to_integer(&1))

    meta =
      Enum.reduce(members, [], fn %{role_id: role, user_id: member_user_id}, acc ->
        if member_user_id == sender_user_id or member_user_id in online_users do
          case Messages.create_message_meta(%{
                 user_id: member_user_id,
                 message_id: message_id,
                 read: true,
                 sent: sent
               }) do
            {:ok, message_meta} ->
              TudoChatWeb.Endpoint.broadcast(
                "user:user_id:#{member_user_id}",
                "user",
                %{
                  last_message: message_for_rest_socket,
                  unread_message_count: 0
                }
              )

              #          push_unread_message_counter_in_socket(group_id, member_user_id, message)
              #          push_total_unread_message_counter_in_socket(member_user_id, group_type, role)
              [message_meta | acc]

            _ ->
              acc
          end
        else
          case Messages.create_message_meta(%{
                 user_id: member_user_id,
                 message_id: message_id,
                 sent: sent
               }) do
            {:ok, message_meta} ->
              push_total_unread_message_counter_in_socket(member_user_id, group_type, role)

              TudoChatWeb.Endpoint.broadcast(
                "user:user_id:#{member_user_id}",
                "user",
                %{
                  last_message: message_for_rest_socket,
                  unread_message_count: get_unread_message_count(group_id, member_user_id)
                }
              )

              [message_meta | acc]

            _ ->
              acc
          end
        end
      end)

    {:ok, meta}
  end

  defp create_message_meta(effects_so_far, params) do
    logger(__MODULE__, effects_so_far, :info, __ENV__.line)
    logger(__MODULE__, params, :info, __ENV__.line)
    params
  end

  def send_message_notification(_, %{is_send_notification: false}),
    do: {:ok, ["No need to send notification"]}

  def send_message_notification(
        %{message: %{id: _msg_id, group_id: group_id, message: message, user_from_id: user_from}},
        _
      ) do
    member_user_ids = Groups.get_group_member_user_ids_by_group(group_id)

    joined_users =
      Presence.list("message_created:group_id:#{group_id}")
      |> Map.keys()
      |> Enum.map(&String.to_integer(&1))

    #    don't send notification to Message sender and channel joined users
    exclusions = if user_from, do: [user_from] ++ joined_users, else: joined_users
    user_ids = member_user_ids -- exclusions

    Exq.enqueue(
      Exq,
      "default",
      #       Timex.shift(DateTime.utc_now(), seconds: 2),
      "TudoChatWeb.Workers.NotifyWorker",
      [
        user_ids,
        message,
        %{user_from: user_from}
      ]
    )

    {:ok, ["notification sent!"]}
  end

  def update_group(%{message: message}, _) do
    with %TudoChat.Groups.Group{} = group <- Groups.get_group(message.group_id),
         {:ok, updated_group} <-
           Groups.update_group(group, %{last_message_at: message.inserted_at}) do
      {:ok, updated_group}
    else
      nil -> {:ok, ["Group Not Found"]}
      {:error, _error} -> {:error, ["Something went wrommg while updating group last message"]}
    end
  end

  def get_unread_message_count(group_id, member_user_id) do
    Messages.get_unread_messages_count_by_group_and_user(%{
      group_id: group_id,
      user_id: member_user_id
    })
  end

  def push_unread_message_counter_in_socket(group_id, member_user_id, message) do
    count = get_unread_message_count(group_id, member_user_id)
    #  Graphql publishing
    Absinthe.Subscription.publish(
      TudoChatWeb.Endpoint,
      %{unread_message_counter: count, user_id: member_user_id},
      unread_group_messages: "group_id:#{group_id},user_id:#{member_user_id}"
    )

    #  rest publishing
    TudoChatWeb.Endpoint.broadcast(
      "unread_group_messages:group_id:#{group_id}",
      "unread_group_messages",
      %{
        unread_group_messages: %{
          unread_message_counter: count,
          user_id: member_user_id,
          message: message
        }
      }
    )
  end

  def push_total_unread_message_counter_in_socket(member_user_id, group_type, role \\ "") do
    case group_type do
      "bus_net" ->
        case role do
          "member" ->
            count =
              Messages.get_unread_messages_count_by_user_and_group_type(member_user_id, "bus_net")

            # TODO: Needed to add -1 in the replacement of count. Example: count = 5---> 5-1 = 4
            my_net_unread_message_socket(member_user_id, count)

          _ ->
            count =
              Messages.get_unread_messages_count_by_user_and_group_type(member_user_id, "bus_net")

            #            employees = Core.Employees.get_employees_by_user_id(member_user_id)
            employees = apply(Core.Employees, :get_employees_by_user_id, [member_user_id])

            Enum.map(employees, fn %{id: id, branch_id: branch_id} ->
              bus_net_unread_message_socket(id, branch_id, count)
            end)
        end

      "my_net" ->
        count =
          Messages.get_unread_messages_count_by_user_and_group_type(member_user_id, "my_net")

        my_net_unread_message_socket(member_user_id, count)

      exception ->
        logger(__MODULE__, exception, ["Group type is not correct"], __ENV__.line)
    end
  end

  defp bus_net_unread_message_socket(employee_id, branch_id, count) do
    #    case Core.MetaData.get_dashboard_meta_by_employee_id(employee_id, branch_id, "dashboard") do
    case apply(Core.MetaData, :get_dashboard_meta_by_employee_id, [
           employee_id,
           branch_id,
           "dashboard"
         ]) do
      [] ->
        {:ok, ["valid"]}

      [data] ->
        {_, %{statistics: updated_statistics}} =
          get_and_update_in(data.statistics["bus_net"]["count"], &{&1, count})

        #        case Core.MetaData.update_meta_bsp(data, %{statistics: updated_statistics}) do
        case apply(Core.MetaData, :update_meta_bsp, [data, %{statistics: updated_statistics}]) do
          {:ok, data} ->
            Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_bsp_socket: "*")

            #            data = Map.drop(data, [:__struct__, :__meta__, :employee, :branch, :user])
            apply(CoreWeb.Endpoint, :broadcast, [
              "meta_bsp:employee_id:#{employee_id}",
              "meta_bsp",
              %{statistics: updated_statistics}
            ])

            {:ok, data}

          exception ->
            logger(__MODULE__, exception, :info, __ENV__.line)
            {:ok, ["valid"]}
        end

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        {:ok, ["valid"]}
    end
  end

  defp my_net_unread_message_socket(member_user_id, count) do
    #    case Core.MetaData.get_dashboard_meta_by_user_id(member_user_id, "dashboard") do
    case apply(Core.MetaData, :get_dashboard_meta_by_user_id, [member_user_id, "dashboard"]) do
      [] ->
        {:ok, ["valid"]}

      [data] ->
        {_, %{statistics: updated_statistics}} =
          get_and_update_in(data.statistics["my_net"]["count"], &{&1, count})

        #        case Core.MetaData.update_meta_cmr(data, %{statistics: updated_statistics}) do
        case apply(Core.MetaData, :update_meta_cmr, [data, %{statistics: updated_statistics}]) do
          {:ok, data} ->
            Absinthe.Subscription.publish(CoreWeb.Endpoint, data, meta_cmr_socket: "*")
            data = Map.drop(data, [:__struct__, :__meta__, :user])

            apply(CoreWeb.Endpoint, :broadcast, [
              "meta_cmr:user_id:#{member_user_id}",
              "meta_cmr",
              %{statistics: updated_statistics}
            ])

            {:ok, data}

          exception ->
            logger(__MODULE__, exception, :info, __ENV__.line)
            {:ok, ["valid"]}
        end

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        {:ok, ["valid"]}
    end
  end
end
