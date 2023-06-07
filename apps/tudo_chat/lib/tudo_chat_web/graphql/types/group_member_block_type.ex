defmodule TudoChatWeb.GraphQL.Types.GroupMemberBlockType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :member_block_type do
    field :id, :id
    field :user_from_id, :integer
    field :user_to_id, :integer
    field :group, :group_type, resolve: assoc(:group)
  end

  input_object :block_input_type do
    field :block, non_null(:boolean)
    field :user_to_id, non_null(:integer)
    field :group_id, non_null(:integer)
  end

  input_object :block_get_by_type do
    field :group_id, non_null(:integer)
  end
end
