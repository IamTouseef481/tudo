defmodule CoreWeb.GraphQL.Types.SessionType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :session_type do
    field :token, :string
    field :user, :user_type
  end

  object :logout_type do
    field(:meta, :json)
  end

  input_object :session_logout_type do
    field :token, non_null(:string)
    field :fcm_token, :string
    field :device_token, :string
  end

  input_object :session_input_type do
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :device_token, :string
    field :fcm_token, :string
    field :os, :string
  end

  input_object :session_send_input_type do
    field :email, non_null(:string)
    field :device_token, non_null(:string)
    field :fcm_token, :string
    field :purpose, non_null(:string)
    field :os, non_null(:string)
  end

  input_object :session_forget_input_type do
    field :email, non_null(:string)
    field :token, non_null(:integer)
    field :password, non_null(:string)
  end
end
