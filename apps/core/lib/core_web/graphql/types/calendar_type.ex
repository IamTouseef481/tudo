defmodule CoreWeb.GraphQL.Types.CalendarType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :calendar_type do
    field :id, :id
    field :schedule, :json
    field :user, :user_type, resolve: assoc(:user)
    #    field :employee, :employee_type, resolve: assoc(:employee)
  end

  object :schedule_type do
    field :jobs, list_of(:job_type)
    field :tasks, :json
    field :events, :json
  end

  input_object :calendar_get_type do
    field :user_id, :integer
    #    field :employee_id, :integer
  end
end
