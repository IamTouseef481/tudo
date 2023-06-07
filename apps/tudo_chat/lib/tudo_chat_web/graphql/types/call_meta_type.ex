defmodule TudoChatWeb.GraphQL.Types.CallMetaType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :call_meta_type do
    field(:id, :id)
    field(:call_start_time, :datetime)
    field(:call_end_time, :datetime)
    field(:call_duration, :time)
    field(:amidn, :boolean)
    field(:status, :string)
    field(:call_id, :integer)
    field :user, :user_type
  end

  object :call_detail_type do
    field(:call_participants, list_of(:call_meta_type))
    field(:call_id, :integer)
  end

  input_object :call_meta_input_type do
    field(:call_id, non_null(:integer))
  end
end
