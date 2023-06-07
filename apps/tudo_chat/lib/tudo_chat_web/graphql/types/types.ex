defmodule TudoChatWeb.GraphQL.Types do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type
  alias TudoChatWeb.GraphQL.Types

  import_types(Absinthe.Type.Custom)
  import_types(Types.CustomTypes)
  import_types(Types.ChannelType)
  import_types(Types.UserType)
  import_types(Types.SessionType)
  import_types(Types.GroupTypesType)
  import_types(Types.GroupType)
  import_types(Types.GroupMemberType)
  import_types(Types.MessageType)
  import_types(Types.PostType)
  import_types(Types.CommentType)
  import_types(Types.FriendCircleType)
  import_types(Types.SearchPersonType)
  import_types(Types.SettingType)
  import_types(Types.GroupMemberBlockType)
  import_types(Types.FileType)
  import_types(Types.CallMetaType)
  import_types(Types.CallType)
end
