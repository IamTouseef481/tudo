defmodule TudoChatWeb.GraphQL.Types.SessionType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :session_type do
    field :token, :string
    field :user, :user_type
  end

  input_object :session_input_type do
    field :email, non_null(:string)
    field :tenant, non_null(:string)
    field :password, non_null(:string)
  end
end
