defmodule CoreWeb.GraphQL.Types.UserInstallsType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :user_installs_type do
    field :device_info, :json
    field :device_token, :string
    field :fcm_token, :string
    field :os, :string
    field :user_id, :id
  end

  input_object :device_info_input_type do
    field :manufacture, :string
    field :device, :string
  end

  input_object :user_installs_input_type do
    field :device_info, :device_info_input_type
    field :device_token, non_null(:string)
    field :fcm_token, :string
    field :os, :string
    field :user_id, :id
  end

  input_object :user_installs_update_type do
    field :device_token, non_null(:string)
    field :device_info, :device_info_input_type
    field :fcm_token, :string
    field :os, :string
    field :user_id, :id
  end

  input_object :user_install_fcm_token_update_type do
    field :fcm_token, non_null(:string)
    field :device_token, non_null(:string)
  end
end
