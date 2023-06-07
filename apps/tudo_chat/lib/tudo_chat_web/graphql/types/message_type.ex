defmodule TudoChatWeb.GraphQL.Types.MessageType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type
  import Ecto.Query
  alias TudoChat.{Accounts.User, Groups.Group}

  object :message_type do
    field :id, :id
    field :content_type, :string
    field :is_active, :boolean
    field :is_personal, :boolean
    field :forwarded, :boolean
    field :message, :string
    field :message_file, :json
    field :user_from_id, :integer
    field :user_to_id, :integer
    field :tagged_user_ids, list_of(:integer)
    field :parent_message_id, :integer
    field :created_at, :datetime
    field :job_status, :job_status_type, resolve: assoc(:job_status)
    field :message_meta, list_of(:message_read_type)
    field :user_group, :group_type
    field :group, :group_type, resolve: assoc(:group)
    #      field :user_to, :user_type, resolve: assoc(:user_to)
    #      field :user_from, :user_type, resolve: assoc(:user_from)

    #      field :user_from, :user_type do
    #        resolve fn message, _, _ ->
    #          batch({__MODULE__, :users_by_id}, message.user_from_id, fn batch_results ->
    #            {:ok, Map.get(batch_results, message.user_from_id)}
    #          end)
    #        end
    #      end
    #      field :user_to, :user_type do
    #        resolve fn message, _, _ ->
    #          batch({__MODULE__, :users_by_id}, message.user_to_id, fn batch_results ->
    #            {:ok, Map.get(batch_results, message.user_to_id)}
    #          end)
    #        end
    #      end
    #      field :group, :group_type do
    #        resolve fn message, _, _ ->
    #          batch({__MODULE__, :group_by_id}, message.group_id, fn batch_results ->
    #            {:ok, Map.get(batch_results, message.group_id)}
    #          end)
    #        end
    #      end
  end

  object :message_download_type do
    field :group_id, :integer
    field :messages, list_of(:message_type)
  end

  object :job_status_type do
    field :id, :string
    field :description, :string
  end

  object :unread_messages_type do
    field :unread_message_counter, :integer
    field :user_id, :integer
    #      field :messages, list_of :message_type
  end

  object :message_meta_type do
    field :id, :id
    field :user_id, :integer
    field :liked, :boolean
    field :favourite, :boolean
    field :sent, :boolean
    field :read, :boolean
    field :deleted, :boolean
    field :message, :message_type, resolve: assoc(:message)
  end

  object :message_read_type do
    field :user_id, :integer
    field :liked, :boolean
    field :favourite, :boolean
    field :read, :boolean
  end

  input_object :message_input_type do
    field :group_id, non_null(:integer)
    field :content_type, :string
    field :is_active, :boolean
    field :is_personal, :boolean
    field :forwarded, :boolean
    field :message, :string
    field :message_file, :message_file
    field :tagged_user_ids, list_of(:integer)
    #      field :user_to_id, :integer
    #      field :user_from_id, :integer
    field :parent_message_id, :integer
  end

  #    input_object :path do
  #      field :thumb, :string
  #      field :original, :string
  #    end

  input_object :message_file do
    field :original, :string
  end

  input_object :message_get_by_group_type do
    field :group_id, non_null(:integer)
    field :favourite, :boolean
    field :read, :boolean
    field :liked, :boolean
    field :ascending_order, :boolean
    field :search_pattern, :string
  end

  input_object :messages_download_by_group_type do
    field :group_ids, non_null(list_of(:integer))
    field :path, non_null(:string)
  end

  input_object :message_meta_update_type do
    field :message_id, non_null(:integer)
    field :liked, :boolean
    field :favourite, :boolean
    field :sent, :boolean
    field :read, :boolean
    field :deleted, :boolean
  end

  input_object :message_socket_join_type do
    field :group_id, non_null(:integer)
  end

  input_object :unread_group_messages_get_socket_type do
    field :group_id, non_null(:integer)
    field :user_id, non_null(:integer)
  end

  input_object :unread_messages_get_socket_type do
    field :user_id, non_null(:integer)
  end

  #    input_object :message_meta_update_type do
  #      field :id, no_null :integer
  #      field :liked, :boolean
  #      field :favourite, :boolean
  #      field :read, :boolean
  #      field :deleted, :boolean
  #    end

  def users_by_id(_, ids) do
    User
    |> where([m], m.id in ^ids)
    |> TudoChat.Repo.all(prefix: Triplex.to_prefix("tudo_"))
    |> Map.new(&{&1.id, &1})
  end

  def group_by_id(_, ids) do
    Group
    |> where([m], m.id in ^ids)
    |> TudoChat.Repo.all(prefix: Triplex.to_prefix("tudo_"))
    |> Map.new(&{&1.id, &1})
  end
end
