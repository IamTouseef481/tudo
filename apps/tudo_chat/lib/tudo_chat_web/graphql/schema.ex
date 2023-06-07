defmodule TudoChatWeb.GraphQL.Schema do
  @moduledoc false
  use TudoChatWeb.GraphQL, :schema
  alias TudoChatWeb.GraphQL.{Middleware, Resolvers}

  # Import Types
  import_types(TudoChatWeb.GraphQL.Types)

  query do
    @desc "Get a list of all group types"
    field :group_types, list_of(:group_types_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupTypesResolver.group_types/3)
    end

    @desc "Get a list of all group statuses"
    field :group_statuses, list_of(:group_status_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupResolver.group_statuses/3)
    end

    @desc "Get a list of all friend circle statuses"
    field :friend_circle_statuses, list_of(:friend_circle_status_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.FriendCircleResolver.friend_circle_statuses/3)
    end

    @desc "Get a list of all groups"
    field :groups, list_of(:group_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupResolver.groups/3)
    end

    @desc "Get a list of all channels"
    field :channels, list_of(:channel_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.ChannelResolver.channels/3)
    end

    @desc "Get a list of all users"
    field :users, list_of(:user_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.UserResolver.users/3)
    end

    @desc "Get a list of all members"
    field :group_members, list_of(:group_member_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupMemberResolver.group_members/3)
    end

    @desc "Get a list of all com group messages"
    field :messages, list_of(:message_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.MessageResolver.com_group_messages/3)
    end

    @desc "Get a list of all posts"
    field :posts, list_of(:post_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.PostResolver.posts/3)
    end

    @desc "Get a list of all comments"
    field :comments, list_of(:comment_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.CommentResolver.comments/3)
    end

    @desc "Get a list of all calls"
    field :get_calls, list_of(:call_listing_type) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.CallResolver.calls/3)
    end
  end

  mutation do
    @desc "create a post"
    field :create_post, type: :post_type do
      # Resolver
      arg(:input, non_null(:post_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.PostResolver.create_post/3)
    end

    @desc "create a comment"
    field :create_comment, type: :comment_type do
      # Resolver
      arg(:input, non_null(:comment_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.CommentResolver.create_comment/3)
    end

    @desc "create a group type"
    field :create_group_type, type: :group_types_type do
      # Resolver
      arg(:input, non_null(:group_types_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupTypesResolver.create_group_type/3)
    end

    @desc "update a group type"
    field :update_group_type, type: :group_types_type do
      # Resolver
      arg(:input, non_null(:group_types_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupTypesResolver.update_group_type/3)
    end

    @desc "delete a group type"
    field :delete_group_type, type: :group_types_type do
      # Resolver
      arg(:input, non_null(:group_types_get_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupTypesResolver.delete_group_type/3)
    end

    @desc "create a group status"
    field :create_group_status, type: :group_status_type do
      # Resolver
      arg(:input, non_null(:group_status_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupResolver.create_group_status/3)
    end

    @desc "update a group status"
    field :update_group_status, type: :group_status_type do
      # Resolver
      arg(:input, non_null(:group_status_update_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupResolver.update_group_status/3)
    end

    @desc "delete a group status"
    field :delete_group_status, type: :group_status_type do
      # Resolver
      arg(:input, non_null(:group_status_get_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupResolver.delete_group_status/3)
    end

    @desc "create a friend circle status"
    field :create_friend_circle_status, type: :friend_circle_status_type do
      # Resolver
      arg(:input, non_null(:friend_circle_status_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.FriendCircleResolver.create_friend_circle_status/3)
    end

    @desc "update a friend circle status"
    field :update_friend_circle_status, type: :friend_circle_status_type do
      # Resolver
      arg(:input, non_null(:friend_circle_status_update_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.FriendCircleResolver.update_friend_circle_status/3)
    end

    @desc "delete a friend_circle status"
    field :delete_friend_circle_status, type: :friend_circle_status_type do
      # Resolver
      arg(:input, non_null(:friend_circle_status_get_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.FriendCircleResolver.delete_friend_circle_status/3)
    end

    @desc "search persons"
    field :search_persons, type: list_of(:user_type) do
      # Resolver
      arg(:input, non_null(:search_person_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.SearchPersonResolver.search_persons/3)
    end

    @desc "create a friend circle"
    field :create_friend_circle, type: :friend_circle_type do
      # Resolver
      arg(:input, non_null(:friend_circle_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.FriendCircleResolver.create_friend_circle/3)
    end

    @desc "update a friend circle"
    field :update_friend_circle, type: :friend_circle_type do
      # Resolver
      arg(:input, non_null(:friend_circle_update_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.FriendCircleResolver.update_friend_circle/3)
    end

    @desc "get a friend_circle"
    field :get_friend_circle, type: :friend_circle_type do
      # Resolver
      arg(:input, non_null(:friend_circle_get_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.FriendCircleResolver.get_friend_circle/3)
    end

    @desc "get a friend_circle by sender"
    field :get_friend_circle_by_sender, type: list_of(:friend_circle_type) do
      # Resolver
      arg(:input, non_null(:friend_circle_get_by_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.FriendCircleResolver.get_friend_circle_by_sender/3)
    end

    @desc "get a friend circle by receiver"
    field :get_friend_circle_by_receiver, type: list_of(:friend_circle_type) do
      # Resolver
      #      arg(:input, non_null(:friend_circle_get_by_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.FriendCircleResolver.get_friend_circle_by_receiver/3)
    end

    @desc "delete a friend_circle"
    field :delete_friend_circle, type: :friend_circle_type do
      # Resolver
      arg(:input, non_null(:friend_circle_get_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.FriendCircleResolver.delete_friend_circle/3)
    end

    @desc "create user setting"
    field :create_setting, type: :setting_type do
      # Resolver
      arg(:input, non_null(:setting_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.SettingResolver.create_settings/3)
    end

    @desc "update user setting"
    field :update_setting, type: :setting_type do
      # Resolver
      arg(:input, non_null(:setting_update_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.SettingResolver.update_settings/3)
    end

    @desc "get user setting by"
    field :get_setting_by, type: list_of(:setting_type) do
      # Resolver
      arg(:input, non_null(:setting_get_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.SettingResolver.settings_by_type/3)
    end

    @desc "create group setting"
    field :create_group_setting, type: :group_setting_type do
      # Resolver
      arg(:input, non_null(:group_setting_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.SettingResolver.create_group_settings/3)
    end

    @desc "update group setting"
    field :update_group_setting, type: :group_setting_type do
      # Resolver
      arg(:input, non_null(:group_setting_update_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.SettingResolver.update_group_settings/3)
    end

    @desc "get group setting by"
    field :get_group_setting, type: list_of(:group_setting_type) do
      # Resolver
      arg(:input, non_null(:group_setting_get_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.SettingResolver.get_group_settings/3)
    end

    @desc "create a group"
    field :create_group, type: :group_type do
      # Resolver
      arg(:input, non_null(:group_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupResolver.create_group/3)
    end

    @desc "update a group"
    field :update_group, type: :group_type do
      # Resolver
      arg(:input, non_null(:group_update_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupResolver.update_group/3)
    end

    @desc "get group"
    field :get_group, type: :group_type do
      # Resolver
      arg(:input, non_null(:group_get_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupResolver.get_group/3)
    end

    @desc "get groups by"
    field :get_groups_by, type: list_of(:group_type) do
      # Resolver
      arg(:input, :group_get_by_type)
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupResolver.get_groups_by/3)
    end

    #    @desc "get groups by"
    #    field :get_groups_by, type: list_of :group_type do
    #      # Resolver
    #      arg(:input, :group_get_by_type)
    #      middleware(Middleware.Authorize, :any)
    #      resolve(&Resolvers.GroupResolver.get_groups_by/3)
    #    end

    @desc "create group members"
    field :create_group_members, type: list_of(:group_member_type) do
      # Resolver
      arg(:input, non_null(:group_member_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupMemberResolver.create_group_members/3)
    end

    @desc "update a group member"
    field :update_group_member, type: :group_member_type do
      # Resolver
      arg(:input, non_null(:group_member_update_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupMemberResolver.update_group_member/3)
    end

    @desc "delete a group member"
    field :delete_group_member, type: :group_member_type do
      # Resolver
      arg(:input, non_null(:group_member_delete_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupMemberResolver.delete_group_member/3)
    end

    @desc "blocking group member"
    field :blocking_group_members, type: :member_block_type do
      # Resolver
      arg(:input, non_null(:block_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupMemberBlockResolver.blocking_group_member/3)
    end

    @desc "get group member blocks for a user"
    field :get_group_member_blocks, type: list_of(:member_block_type) do
      # Resolver
      arg(:input, non_null(:block_get_by_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.GroupMemberBlockResolver.block_get_by/3)
    end

    @desc "create a com group message"
    field :create_message, type: :message_type do
      # Resolver
      arg(:input, non_null(:message_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.MessageResolver.create_com_group_message/3)
    end

    @desc "Get Files"
    field :get_message_files, list_of(:json) do
      # Resolver
      middleware(Middleware.Authorize, :any)
      arg(:input, list_of(:message_file))
      resolve(&Resolvers.FileResolver.get_message_files/3)
    end

    @desc "get com group messages of a group"
    field :get_messages_by_group, type: list_of(:message_type) do
      # Resolver
      arg(:input, non_null(:message_get_by_group_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.MessageResolver.get_messages_by_group/3)
    end

    @desc "download com group messages by groups"
    field :download_messages_by_group, type: list_of(:message_download_type) do
      # Resolver
      arg(:input, non_null(:messages_download_by_group_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.MessageResolver.download_messages_by_group/3)
    end

    @desc "update message meta"
    field :update_message_meta, type: list_of(:message_meta_type) do
      # Resolver
      arg(:input, list_of(non_null(:message_meta_update_type)))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.MessageResolver.update_message_meta/3)
    end

    @desc "create a user"
    field :create_user, type: :user_type do
      # Resolver
      arg(:input, non_null(:user_input_type))
      resolve(&Resolvers.UserResolver.create_user/3)
    end

    @desc "login a user"
    field :login_user, type: :session_type do
      # Resolver
      arg(:input, non_null(:session_input_type))
      resolve(&Resolvers.SessionResolver.login_user/3)
    end

    @desc "create a channel"
    field :create_channel, type: :channel_type do
      # Resolver
      arg(:input, non_null(:channel_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.ChannelResolver.create_channel/3)
    end

    @desc "get call meta"
    field :get_call_meta, type: list_of(:call_detail_type) do
      # Resolver
      arg(:input, non_null(:call_meta_input_type))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.CallMetaResolver.get_call_meta/3)
    end
  end

  subscription do
    field :create_user, type: :user_type do
      config(fn _, _ ->
        {:ok, topic: true}
      end)
    end

    field :message_created, type: :message_type do
      arg(:input, non_null(:message_socket_join_type))
      #      resolve(&Resolvers.MessageResolver.join_message_socket/3)
      config(fn params, _ ->
        {:ok, topic: params.input.group_id}
      end)
    end

    field :unread_group_messages, type: :unread_messages_type do
      arg(:input, non_null(:unread_group_messages_get_socket_type))

      config(fn params, _ ->
        {:ok, topic: "group_id:#{params.input.group_id},user_id:#{params.input.user_id}"}
      end)
    end

    field :total_unread_messages, type: :unread_messages_type do
      arg(:input, non_null(:unread_messages_get_socket_type))

      config(fn params, _ ->
        {:ok, topic: "user_id:#{params.input.user_id}"}
      end)
    end
  end
end
