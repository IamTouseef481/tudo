defmodule TudoChatWeb.GraphQL.Types.ChannelType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :channel_type do
    field(:id, :id)
    field(:name, non_null(:string))
    field(:desc, non_null(:string))
    field(:status, non_null(:string))
  end

  input_object :channel_input_type do
    field(:name, non_null(:string))
    field(:desc, non_null(:string))
    field(:status, non_null(:string))
  end
end
