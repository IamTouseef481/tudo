defmodule CoreWeb.GraphQL.Types.OffDayType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :holiday_type do
    field :id, :id
    field :title, :string
    field :type, :string
    field :description, :string
    field :from, :datetime
    field :to, :datetime
    field :branch, :branch_type, resolve: assoc(:branch)
  end

  input_object :holiday_input_type do
    field :title, non_null(:string)
    field :type, :string
    field :description, :string
    field :from, non_null(:datetime)
    field :to, non_null(:datetime)
    field :branch_id, non_null(:integer)
  end

  input_object :holiday_update_type do
    field :id, non_null(:integer)
    field :title, :string
    field :type, :string
    field :description, :string
    field :from, :datetime
    field :to, :datetime
    field :branch_id, :integer
  end

  input_object :holiday_delete_type do
    field :id, non_null(:integer)
  end

  input_object :holiday_get_type do
    field :from, non_null(:datetime)
    field :to, non_null(:datetime)
    field :branch_id, non_null(:integer)
  end
end
