defmodule TudoChatWeb.Controllers.MessageController do
  @moduledoc false
  use TudoChatWeb, :controller
  alias TudoChat.{GroupMemberBlocks, Groups, Messages}
  alias TudoChatWeb.Channels.UserChannel
  alias TudoChatWeb.Helpers.MessageHelper

  @default_error ["Unexpected error occurred"]

  def create_com_group_message(input) do
    with {:ok, _last, all} <- MessageHelper.create_com_group_message(input),
         %{message_socket: message} <- all do
      {:ok, message}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, @default_error, __ENV__.line)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  #  upsert delete meta
  def update_message_meta(%{user_id: user_id, message_id: message_id, deleted: true} = input) do
    case Messages.get_com_group_message(message_id) do
      nil ->
        {:error, ["message doesn't exist!"]}

      %{inserted_at: message_created_at} ->
        if Timex.diff(DateTime.utc_now(), message_created_at, :seconds) < 3600 do
          group = Messages.get_group_with_message_id(message_id)

          TudoChatWeb.Endpoint.broadcast(
            "user:user_id:#{user_id}",
            "message_deleted",
            %{
              last_message:
                UserChannel.create_message_socket(
                  Messages.get_last_message_by_group_and_user(group.group_id, user_id)
                )
            }
          )

          updates_message_meta(input, "")
        else
          {:error, ["after 1 hour you can't delete your message!"]}
        end

      exception ->
        logger(__MODULE__, exception, @default_error, __ENV__.line)
    end
  end

  #  upsert meta other than delete
  def update_message_meta(%{user_id: user_id, message_id: message_id} = input) do
    case Messages.get_com_group_message(message_id) do
      %{group_id: group_id} ->
        case Groups.get_group_member_by(%{group_id: group_id, user_id: user_id}) do
          [%{role_id: role}] ->
            updates_message_meta(input, role)

          exception ->
            logger(__MODULE__, exception, ["Some Error while getting group member"], __ENV__.line)
        end

      exception ->
        logger(__MODULE__, exception, ["Message Does not exist"], __ENV__.line)
    end
  end

  defp updates_message_meta(%{user_id: user_id, message_id: message_id} = input, role) do
    case Messages.get_message_meta_by_user_and_message(user_id, message_id) do
      #      [] -> create_message_meta(input)
      [] -> {:error, ["message meta doesn't exist"]}
      [meta] -> updating_message_meta(meta, input, role)
      _meta -> {:error, ["more than one message meta records"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  #  defp create_message_meta(input) do
  #    case Messages.get_com_group_message(input.message_id) do
  #      %{group_id: group_id} ->
  #        case Messages.create_message_meta(input) do
  #          {:ok, message_meta} ->
  #            MessageHelper.push_unread_message_counter_in_socket(group_id, input.user_id)
  #            MessageHelper.push_total_unread_message_counter_in_socket(input.user_id)
  #            {:ok, message_meta}
  #          {:error, error} -> {:error, error}
  #          _ -> {:error, ["something went wrong while creating meta!"]}
  #        end
  #      _ -> {:error, ["error while fetching group from message"]}
  #    end
  #  end

  defp updating_message_meta(meta, input, role) do
    case Messages.get_com_group_message(input.message_id) do
      %{group_id: group_id, message: message} ->
        case Messages.update_message_meta(meta, input) do
          {:ok, message_meta} ->
            type =
              case Groups.get_group(group_id) do
                %{group_type_id: group_type} -> group_type
                _ -> nil
              end

            MessageHelper.push_unread_message_counter_in_socket(
              group_id,
              meta.user_id,
              message
            )

            MessageHelper.push_total_unread_message_counter_in_socket(
              meta.user_id,
              type,
              role
            )

            {:ok, message_meta}

          {:error, error} ->
            {:error, error}

          exception ->
            logger(
              __MODULE__,
              exception,
              ["Something went wrong while updating message meta"],
              __ENV__.line
            )
        end

      exception ->
        logger(__MODULE__, exception, ["Error while fetching group from message"], __ENV__.line)
    end
  end

  def get_messages_by_group(%{group_id: group_id} = input) do
    case Groups.get_group(group_id) do
      %{group_type_id: type} ->
        if type == "bus_net" do
          #          min_duration_limit = Timex.shift(DateTime.utc_now(), months: -6)
          #         fetch all members of group, check owner of business, fetch branch from business and package plan from this
          #         set min_duration_limit accordingly, on free package, one month limit

          query = Messages.get_bus_net_messages_query(input)

          TudoChatWeb.Endpoint.broadcast(
            "user:user_id:#{input.user_id}",
            "message_listing",
            %{
              last_message:
                UserChannel.create_message_socket(
                  Messages.get_last_message_by_group_and_user(input.group_id, input.user_id)
                )
            }
          )

          get_group_messages_for_active_members(input, query)
        else
          min_duration_limit = Timex.shift(DateTime.utc_now(), months: -6)
          query = Messages.get_my_net_messages_query(input, min_duration_limit)

          TudoChatWeb.Endpoint.broadcast(
            "user:user_id:#{input.user_id}",
            "message_listing",
            %{
              last_message:
                UserChannel.create_message_socket(
                  Messages.get_last_message_by_group_and_user(input.group_id, input.user_id)
                )
            }
          )

          get_group_messages_for_active_members(input, query)
        end
    end
  end

  def get_group_messages_for_active_members(input, query) do
    case GroupMemberBlocks.get_blocked_group_members(input) do
      [] ->
        get_group_messages(query, input)

      blocks ->
        query
        |> Messages.exclude_messages_of_blocked_members_query(Enum.map(blocks, & &1.user_to_id))
        |> get_group_messages(input)
    end
  end

  def get_group_messages(query, input) do
    query =
      Enum.reduce(Map.keys(input), query, fn key, query_acc ->
        case key do
          :read -> Messages.get_read_messages_query(query_acc, input)
          :favourite -> Messages.get_favourite_messages_query(query_acc, input)
          :liked -> Messages.get_liked_messages_query(query_acc, input)
          :search_pattern -> Messages.get_searched_messages_query(query_acc, input)
          _ -> query_acc
        end
      end)

    %{entries: messages} = Messages.sort_and_get_messages(query, input)

    messages =
      Enum.map(messages, fn %{group_id: group_id} = message ->
        Map.merge(message, %{user_group: preload_group_with_members_and_user(group_id)})
      end)

    {:ok, messages}
  end

  def preload_group_with_members_and_user(group_id) do
    case Groups.get_group_with_members(group_id) do
      %{id: _group_id, group_members: group_members} = group ->
        members =
          Enum.map(group_members, fn %{user_id: user_id} = group_member ->
            Map.merge(group_member, %{user: Core.Accounts.get_user!(user_id)})
          end)

        Map.merge(group, %{user_group_members: members})

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        nil
    end
  end

  def download_messages_by_group(%{path: path, group_ids: group_ids} = input) do
    messages =
      Enum.reduce(group_ids, [], fn group_id, acc ->
        group_messages =
          input
          |> Map.merge(%{group_id: group_id})
          |> Messages.get_group_messages_by_group()

        [%{group_id: group_id, messages: group_messages} | acc]
      end)

    case Poison.encode(messages) do
      {:ok, body} ->
        File.write!("#{path}/chat.json", body)

      exception ->
        logger(__MODULE__, exception, ["Error while encoding message data"], __ENV__.line)
    end

    {:ok, messages}
  end

  def mark_all_group_messages_read_for_this_user(user_id, group_id) do
    unread_meta =
      Messages.get_unread_messages_meta_by_group_and_user(%{group_id: group_id, user_id: user_id})

    if Enum.count(unread_meta) > 0 do
      Enum.each(unread_meta, &Messages.update_message_meta(&1, %{read: true}))
      # subtract_one_from_bus_net_meta(user_id)
      group_type = Groups.get_group_type_by_group_id(group_id)
      role = Groups.get_group_member_role_by(%{group_id: group_id, user_id: user_id})
      last_message = Messages.get_last_message_by_group_and_user(group_id, user_id)
      message_for_rest_socket = UserChannel.create_message_socket(last_message)

      TudoChatWeb.Endpoint.broadcast(
        "user:user_id:#{user_id}",
        "user",
        %{
          last_message: message_for_rest_socket,
          unread_message_count: 0
        }
      )

      MessageHelper.push_total_unread_message_counter_in_socket(
        user_id,
        group_type,
        role
      )
    end
  end

  # defp subtract_one_from_bus_net_meta(user_id) do
  #   employees = apply(Core.Employees, :get_employees_by_user_id, [user_id])

  #   Enum.map(employees, fn %{id: employee_id} ->
  #     %{id: branch_id} = apply(Core.BSP, :get_branch_by_employee_id, [employee_id])

  #     case apply(Core.MetaData, :get_dashboard_meta_by_employee_id, [
  #            employee_id,
  #            branch_id,
  #            "dashboard"
  #          ]) do
  #       [] ->
  #         {:ok, "no needed to update meta"}

  #       [%{} = meta] ->
  #         {_, updated_meta} =
  #           get_and_update_in(meta.statistics["bus_net"]["count"], &{&1, &1 - 1})

  #         apply(Core.MetaData, :update_meta_bsp, [meta, %{statistics: updated_meta.statistics}])
  #     end
  #   end)
  # rescue
  #   exception ->
  #     logger(__MODULE__, exception, :info, __ENV__.line)
  # end
end
