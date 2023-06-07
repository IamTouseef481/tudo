defmodule TudoChatWeb.GraphQL.Resolvers.MessageResolver do
  @moduledoc false
  use TudoChatWeb.GraphQL, :resolver
  alias TudoChat.{Groups, Messages, Settings}
  alias TudoChatWeb.Controllers.MessageController

  @default_error ["unexpected error occurred"]

  def com_group_messages(_, _, _) do
    {:ok, Messages.list_com_group_messages()}
  end

  def create_com_group_message(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_from_id: current_user.id})

    case MessageController.create_com_group_message(input) do
      {:ok, message} ->
        {:ok, message}

      {:error, error} ->
        {:error, error}
        #      _ -> {:error, ["Something went wrong, try again!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_message_meta(_, %{input: input}, %{context: %{current_user: current_user}}) do
    meta =
      Enum.reduce_while(input, [], fn meta, acc ->
        input = Map.merge(meta, %{user_id: current_user.id})

        case meta do
          %{deleted: true} ->
            updating_message_meta(input, meta, acc)

          %{deleted: false} ->
            {:halt, {:error, ["message ##{meta.message_id} is deleted"]}}

          _ ->
            case MessageController.update_message_meta(input) do
              {:ok, message_meta} -> {:cont, [message_meta | acc]}
              _ -> {:cont, acc}
            end
        end
      end)

    case meta do
      {:error, error} -> {:error, error}
      meta -> {:ok, meta}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  defp updating_message_meta(input, meta, acc) do
    case Groups.get_group_by_com_group_message(meta.message_id) do
      nil ->
        {:halt, {:error, ["group against message ##{meta.message_id} does not exist!"]}}

      %{group_type_id: "bus_net"} ->
        {:halt, {:error, ["bus_net group message can't deleted"]}}

      %{group_type_id: _type} ->
        case MessageController.update_message_meta(input) do
          {:ok, message_meta} -> {:cont, [message_meta | acc]}
          {:error, error} -> {:halt, {:error, error}}
        end

      _ ->
        {:halt, {:error, ["error in fetching chat group"]}}
    end
  end

  def get_messages_by_group(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})
    input = add_settings_in_params(input)

    case Groups.get_group_member_by(%{user_id: current_user.id, group_id: input.group_id}) do
      [] ->
        {:error, ["you're not member of this group"]}

      _member ->
        case MessageController.get_messages_by_group(input) do
          {:ok, messages} -> {:ok, messages}
          {:error, error} -> {:error, error}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def add_settings_in_params(input) do
    case Settings.settings_by_slug(%{user_id: input.user_id, slug: "messages_order"}) do
      [%{fields: %{"ascending_order" => order}}] ->
        Map.merge(input, %{ascending_order: order})

      _ ->
        input
    end
  end

  def download_messages_by_group(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case MessageController.download_messages_by_group(input) do
      {:ok, messages} -> {:ok, messages}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  #  def join_message_socket _, %{input: %{group_id: group_id}}, %{context: %{current_user: current_user}} do
  #    case TudoChat.Groups.get_group_member_by(%{user_id: current_user.id, group_id: group_id}) do
  #      [] ->
  #        {:error, ["you're not a member of this group"]}
  #      user ->
  #        {:ok, ["valid member"]}
  #    end
  #  end
end
