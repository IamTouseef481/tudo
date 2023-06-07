defmodule TudoChatWeb.GraphQL.Types.FriendCircleType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :friend_circle_status_type do
    field :id, :string
    field :description, :string
  end

  object :friend_circle_type do
    field :id, :integer
    field :request_message, :string
    field :user_to_id, :integer
    field :user_from_id, :integer
    field :status, :friend_circle_status_type, resolve: assoc(:status)
    field :group, :group_type, resolve: assoc(:group)
  end

  input_object :friend_circle_status_input_type do
    field :id, non_null(:string)
    field :description, :string
  end

  input_object :friend_circle_status_update_type do
    field :id, non_null(:string)
    field :description, :string
  end

  input_object :friend_circle_status_get_type do
    field :id, non_null(:string)
  end

  input_object :friend_circle_input_type do
    field :request_message, :string
    field :user_to_id, non_null(:integer)
  end

  input_object :friend_circle_update_type do
    field :id, non_null(:integer)
    field :request_message, :string
    field :status_id, :string
  end

  input_object :friend_circle_get_type do
    field :id, non_null(:integer)
  end

  input_object :friend_circle_get_by_type do
    field :status_ids, non_null(list_of(:string))
  end
end
