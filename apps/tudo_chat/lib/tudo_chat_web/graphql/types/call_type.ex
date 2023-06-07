defmodule TudoChatWeb.GraphQL.Types.CallType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :call_type do
    field(:id, :id)
    field(:call_start_time, :datetime)
    field(:call_end_time, :datetime)
    field(:call_duration, :time)
    field(:amidn, :boolean)
    field(:status, :string)
    field(:call_id, :integer)
    field :user, :user_type
  end

  object :call_listing_type do
    field(:call_detail, list_of(:call_type))
    field(:call_id, :integer)
  end
end
