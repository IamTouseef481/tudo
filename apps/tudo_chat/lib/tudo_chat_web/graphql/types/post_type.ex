defmodule TudoChatWeb.GraphQL.Types.PostType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :post_type do
    field(:id, non_null(:id))
    field(:title, non_null(:string))
    #    field :user, :user_type, resolve: assoc(:user)
  end

  input_object :post_input_type do
    field :title, non_null(:string)
  end
end
