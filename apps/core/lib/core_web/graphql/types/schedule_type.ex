defmodule CoreWeb.GraphQL.Types.ScheduleType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :user_schedule_type do
    field :id, :id
    field :schedule, :json
    field :user, :user_type, resolve: assoc(:user)
  end

  input_object :user_schedule_input_type do
    field :schedule, :branch_input_type
    field :user_id, :integer
  end

  input_object :user_schedule_update_type do
    field :id, non_null(:integer)
    field :schedule, :branch_input_type
    field :user_id, :integer
  end

  input_object :user_schedule_get_type do
    field :user_id, :integer
  end

  input_object :user_schedule_delete_type do
    field :id, :integer
  end
end
